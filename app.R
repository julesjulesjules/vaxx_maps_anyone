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

census_api_key_read <- read.table("census_api_key_hold.txt")[1, 1]

census_api_key(census_api_key_read) # load API key


ui <- fluidPage(
  
  # Application title
  titlePanel("Mapping Vaccination Data"),
  
  # Sidebar  
  sidebarLayout(
    sidebarPanel(
      radioButtons("county_overlay", h6(strong("County Outlines?")), 
                  choices = c("Yes", "No"), selected = "No"), 
      selectInput("state_choice", h6(strong("State View:")), 
                  choices = c(state.abb), selected = "MI")
    
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
    tracts_out <- tracts(as.character(input$state_choice[1]),county=NULL,2010,cb=T) ## grab tract shapefiles
    tracts_out$GEOID <- as.numeric(gsub("1400000US","",tracts_out$GEO_ID)) # beautifying tract data
    
    return(tracts_out)
  })
  
  county_shp <- reactive({
    county_out <- counties(as.character(input$state_choice[1]),2010,cb=T, resolution = "500k") ## grab county shapefiles
    county_out$GEOID <- as.numeric(gsub("0500000US","",county_out$GEO_ID)) # beautifying tract data
    
    return(county_out)
  })
  
  output$state_map_out <- renderLeaflet({
    
    ct_shp <- census_tract_shp()
    ct_shp$shape <- st_transform(ct_shp$geometry,"+proj=longlat +datum=WGS84") # sf package-geometries into something usable by leaflet
    
    co_shp <- county_shp()
    co_shp$shape <- st_transform(co_shp$geometry,"+proj=longlat +datum=WGS84") # sf package-geometries into something usable by leaflet
    
    
    map.leaf <- leaflet() %>% addPolygons(data = ct_shp$shape, fillColor = "#586F6B",
                                                color = "#D7D9CE", # you need to use hex colors
                                                fillOpacity = 1, 
                                                weight = 1, 
                                                smoothFactor = 0.2) %>%
                              setMapWidgetStyle(list(background= "#292929"))
    
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
