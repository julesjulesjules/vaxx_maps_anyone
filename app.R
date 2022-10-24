library(shiny)
library(tidyverse)
library(lubridate)
library(tidycensus)
library(leaflet)
library(sf)
library(htmlwidgets)
library(tigris)
library(htmltools) 
library(leaflet.extras)
library(censusapi)
library(reshape2)

census_api_key_read <- read.table("census_api_key_hold.txt")[1, 1]

census_api_key(census_api_key_read) # load API key

vaxx_d <- read.csv("./data/vaxx_data_in.csv")

state_num <- read.table("./data/state_number_crosstab.tsv", sep = "\t", header = FALSE, colClasses = c("character", "character"), row.names = NULL, col.names = c("state", "code"))

ui <- fluidPage(
  
  # Application title
  titlePanel("Mapping Vaccination Data"),
  
  # Sidebar  
  sidebarLayout(
    sidebarPanel(
      radioButtons("county_overlay", h6(strong("County Outlines?")), 
                  choices = c("Yes", "No"), selected = "No"), 
      selectInput("state_choice", h6(strong("State View:")), 
                  choices = c(state.abb), selected = "MI"), 
      radioButtons("shp_year_choice", h6(strong("Boundary Year:")), 
                   choices = c("2010", "2020"), selected = "2010"), 
      selectInput("population_inc", h6(strong("Population Inclusion?")), 
                  choices = c("None", ">5 years 2019 ACS", ">18 years 2019 ACS", 
                              "18+ years 2019 ACS", "All 2019 ACS"), selected = "None")
    
    ),
    
    # Show a plot
    mainPanel(
      leafletOutput(outputId = "state_map_out")
    )
)
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  census_tract_shp <- reactive({
    
    tracts_out <- tracts(as.character(input$state_choice),county=NULL,as.numeric(input$shp_year_choice),cb=T) ## grab tract shapefiles
    if (input$shp_year_choice == "2010"){
      tracts_out$GEOID <- as.numeric(gsub("1400000US","",tracts_out$GEO_ID)) # beautifying tract data
    } else if (input$shp_year_choice == "2020"){
      tracts_out$GEOID <- tracts_out$GEOID
    }
    
    return(tracts_out)
  })
  
  county_shp <- reactive({
    county_out <- counties(as.character(input$state_choice[1]),as.numeric(input$shp_year_choice),cb=T, resolution = "500k") ## grab county shapefiles
    if (input$shp_year_choice == "2010"){
      county_out$GEOID <- as.numeric(gsub("0500000US","",county_out$GEO_ID)) # beautifying tract data
    } else if (input$shp_year_choice == "2020"){
      county_out$GEOID <- county_out$GEOID
    }
    return(county_out)
  })
  
  population_choice <- reactive({
    
    state_code <- filter(state_num, state == as.character(input$state_choice[1]))[1, 2]
    
    acs_total <- getCensus(
      name = "acs/acs5", 
      vintage = 2019, 
      vars = c("NAME", "group(B01003)"), 
      region = "tract:*", 
      regionin = paste0("state:", state_code), 
      key = census_api_key_read)
    
  })
  
  output$state_map_out <- renderLeaflet({
    
    ct_shp <- census_tract_shp()
    ct_shp_map <- merge(vaxx_d, ct_shp, by = "GEOID", all.x = TRUE, all.y = TRUE)
    ct_shp_map$shape <- st_transform(ct_shp_map$geometry,"+proj=longlat +datum=WGS84") # sf package-geometries into something usable by leaflet
    
    co_shp <- county_shp()
    co_shp$shape <- st_transform(co_shp$geometry,"+proj=longlat +datum=WGS84") # sf package-geometries into something usable by leaflet
    
    
    popup <- paste0(ct_shp_map$TRACT, "<br>", "Count Vaccinated = ", ct_shp_map$COUNTVAXXED) # what the tooltip will show
    
    pall<-colorBin(c("#FFFFFF","#586F6B"), ct_shp_map$COUNTVAXXED, 10, pretty = T) 
    
    map.leaf <- leaflet() %>% addPolygons(data = ct_shp_map$shape, fillColor = pall(ct_shp_map$COUNTVAXXED),
                                                color = "#D7D9CE", # you need to use hex colors
                                                fillOpacity = 1, 
                                                weight = 1, 
                                                smoothFactor = 0.2, 
                                                popup = popup) %>%
                              setMapWidgetStyle(list(background= "#292929")) %>%
                              addLegend(pal = pall, opacity = 1,
                                values = ct_shp_map$COUNTVAXXED, 
                                position = "bottomright", 
                                title = "Count")
    
    if(input$county_overlay == "Yes"){
      map.leaf <- map.leaf %>% addPolygons(data = co_shp$shape, fillColor = "#B287A3",
                               color = "#000000", # you need to use hex colors
                               fillOpacity = 0.3, 
                               weight = 2, 
                               smoothFactor = 0.2)
    }
    
    return(map.leaf)
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
