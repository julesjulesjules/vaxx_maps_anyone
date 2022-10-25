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

variable_match <- read.csv("./data/matching_vars.csv", stringsAsFactors = FALSE)

ui <- fluidPage(
  
  # Application title
  titlePanel("Mapping Vaccination Data"),
  
  # Sidebar  
  sidebarLayout(
    sidebarPanel(
      selectInput("state_choice", h6(strong("State View:")), 
                  choices = c(state.abb), selected = "MI"), 
      radioButtons("shp_year_choice", h6(strong("Boundary Year:")), 
                   choices = c("2010", "2020"), selected = "2010"), 
      selectInput("population_inc", h6(strong("Population Inclusion?")), 
                  choices = c("None", "<5 years 2019 ACS", "<18 years 2019 ACS", 
                              "18+ years 2019 ACS", "All 2019 ACS"), selected = "None"), 
      radioButtons("county_overlay", h6(strong("County Outlines?")), 
                   choices = c("Yes", "No"), selected = "No"), 
      textInput("title_create", h6(strong("Add a title:"))),
      downloadButton("downloadData", h6(strong("Download Map")))
    
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
    
    state_populations_have <- list.files("./data/2019_acs_populations/")
    
    if (paste0(as.character(input$state_choice[1]), "_2019acs.csv") %in% state_populations_have){
      complete_set_format <- read.csv(paste0("./data/2019_acs_populations/", as.character(input$state_choice[1]), "_2019acs.csv"))
    } else {
    
      state_code <- filter(state_num, state == as.character(input$state_choice[1]))[1, 2]
      
      acs_total <- getCensus(
        name = "acs/acs5", 
        vintage = 2019, 
        vars = c("NAME", "group(B01003)"), 
        region = "tract:*", 
        regionin = paste0("state:", state_code), 
        key = census_api_key_read)
      
      acs_white <- getCensus(
        name = "acs/acs5", 
        vintage = 2019, 
        vars = c("NAME", "group(B01001A)"), 
        region = "tract:*", 
        regionin = paste0("state:", state_code), 
        key = census_api_key_read)
      
      acs_white <- melt(acs_white, id.vars = c("state", "county", "tract", "NAME", "GEO_ID"))
      
      acs_black <- getCensus(
        name = "acs/acs5", 
        vintage = 2019, 
        vars = c("NAME", "group(B01001B)"), 
        region = "tract:*", 
        regionin = paste0("state:", state_code), 
        key = census_api_key_read)
      
      acs_black <- melt(acs_black, id.vars = c("state", "county", "tract", "NAME", "GEO_ID"))
      
      acs_aian <- getCensus(
        name = "acs/acs5", 
        vintage = 2019, 
        vars = c("NAME", "group(B01001C)"), 
        region = "tract:*", 
        regionin = paste0("state:", state_code), 
        key = census_api_key_read)
      
      acs_aian <- melt(acs_aian, id.vars = c("state", "county", "tract", "NAME", "GEO_ID"))
      
      acs_asian <- getCensus(
        name = "acs/acs5", 
        vintage = 2019, 
        vars = c("NAME", "group(B01001D)"), 
        region = "tract:*", 
        regionin = paste0("state:", state_code), 
        key = census_api_key_read)
      
      acs_asian <- melt(acs_asian, id.vars = c("state", "county", "tract", "NAME", "GEO_ID"))
      
      acs_nhpi <- getCensus(
        name = "acs/acs5", 
        vintage = 2019, 
        vars = c("NAME", "group(B01001E)"), 
        region = "tract:*", 
        regionin = paste0("state:", state_code), 
        key = census_api_key_read)
      
      acs_nhpi <- melt(acs_nhpi, id.vars = c("state", "county", "tract", "NAME", "GEO_ID"))
      
      acs_other <- getCensus(
        name = "acs/acs5", 
        vintage = 2019, 
        vars = c("NAME", "group(B01001F)"), 
        region = "tract:*", 
        regionin = paste0("state:", state_code), 
        key = census_api_key_read)
      
      acs_other <- melt(acs_other, id.vars = c("state", "county", "tract", "NAME", "GEO_ID"))
      
      acs_two <- getCensus(
        name = "acs/acs5", 
        vintage = 2019, 
        vars = c("NAME", "group(B01001G)"), 
        region = "tract:*", 
        regionin = paste0("state:", state_code), 
        key = census_api_key_read)
      
      acs_two <- melt(acs_two, id.vars = c("state", "county", "tract", "NAME", "GEO_ID"))
      
      complete_set <- rbind(acs_white, acs_black, acs_aian, acs_asian, acs_nhpi, acs_other, acs_two)
      
      complete_set <- filter(complete_set, !grepl("MA", variable))
      complete_set <- filter(complete_set, !grepl("EA", variable))
      complete_set <- filter(complete_set, !grepl("M", variable))
      
      complete_set$variable <- substr(complete_set$variable, 1, 11)
      
      complete_set <- merge(complete_set, variable_match, by.x = c("variable"), by.y = c("MatchCode"))
      
      complete_set$tract_pull <- sapply(strsplit(complete_set$NAME,","), `[`, 1)
      complete_set$county_pull <- sapply(strsplit(complete_set$NAME,","), `[`, 2)
      complete_set$county <- trimws(gsub("County", "", complete_set$county_pull))
      
      complete_set$GEO_ID <- substr(complete_set$GEO_ID, 10, 21)
      #filter(complete_set, tract == 970400) %>% select(tract, tract_pull, county) %>% distinct()
      
      complete_set2 <- select(complete_set, GEO_ID, tract, county, Description, Sex, Race, value)
      
      complete_set2 <- filter(complete_set2, Description != "Female:" & Description != "Male:" & Description != "Total:")
      complete_set2$value <- as.numeric(complete_set2$value)
      
      complete_set_grouped <- complete_set2 %>% group_by(GEO_ID, county, tract, Description, Sex, Race) %>% summarize(Total = sum(value, na.rm = TRUE))
      
      complete_set_format <- dcast(complete_set_grouped, GEO_ID + county + tract + Description ~ Sex + Race, value.var = c("Total"))
      
      complete_set_format$sum_row <- rowSums(complete_set_format[,5:18] )
      
      complete_set_format <- complete_set_format %>% select(GEO_ID, county, tract, Description, sum_row)
    
      write.csv(complete_set_format, paste0("./data/2019_acs_populations/", as.character(input$state_choice[1]), "_2019acs.csv"), row.names = FALSE, na = "")
    }
    
    return(complete_set_format)
    
  })
  
  
  population_age_group_choice <- reactive({
    
    full_pop <- population_choice()
    
    if (input$population_inc == "<5 years 2019 ACS"){
      
      age_pop <- filter(full_pop, trimws(Description) == "Under 5 years")
      age_pop <- age_pop %>% group_by(GEO_ID, county, tract) %>% summarize(total_pop = sum(sum_row, na.rm = TRUE))
      
    } else if (input$population_inc == "<18 years 2019 ACS"){
      
      age_pop <- filter(full_pop, trimws(Description) %in% c("Under 5 years", "5 to 9 years", "10 to 14 years", "15 to 17 years"))
      age_pop <- age_pop %>% group_by(GEO_ID, county, tract) %>% summarize(total_pop = sum(sum_row, na.rm = TRUE))
      
    } else if (input$population_inc == "18+ years 2019 ACS"){
      
      age_pop <- filter(full_pop, trimws(Description) %in% c("18 and 19 years", "20 to 24 years", "25 to 29 years", "30 to 34 years", 
                                                             "35 to 44 years", "45 to 54 years", "55 to 64 years", "65 to 74 years", 
                                                             "75 to 84 years", "85 years and over"))
      age_pop <- age_pop %>% group_by(GEO_ID, county, tract) %>% summarize(total_pop = sum(sum_row, na.rm = TRUE))
      
    } else if (input$population_inc == "All 2019 ACS"){
      # total
      age_pop <- full_pop %>% group_by(GEO_ID, county, tract) %>% summarize(total_pop = sum(sum_row, na.rm = TRUE))
      
    } else {
      # no pop
      x <- 0
    }
    
   return(age_pop)
    
  })
  
  
  output$state_map_out <- renderLeaflet({
    
    ct_shp <- census_tract_shp()
    ct_shp_map <- merge(vaxx_d, ct_shp, by = "GEOID", all.x = TRUE, all.y = TRUE)
    
    ## add population here, if indicated
    if (input$population_inc != "None"){
      pop_in <- population_age_group_choice()
      ct_shp_map <- merge(ct_shp_map, pop_in, by.x = c("GEOID"), by.y = c("GEO_ID"), all.x = TRUE, all.y = FALSE)
      ct_shp_map <- ct_shp_map %>% mutate(percent = round((COUNTVAXXED / total_pop)*100, 2))
    }
    
    ct_shp_map$shape <- st_transform(ct_shp_map$geometry,"+proj=longlat +datum=WGS84") # sf package-geometries into something usable by leaflet
    
    co_shp <- county_shp()
    co_shp$shape <- st_transform(co_shp$geometry,"+proj=longlat +datum=WGS84") # sf package-geometries into something usable by leaflet
    
    
    
    
    if (input$population_inc != "None"){
      
      popup <- paste0(ct_shp_map$TRACT, "<br>", "Count Vaccinated = ", ct_shp_map$COUNTVAXXED, 
                      "<br>Population = ", ct_shp_map$total_pop, 
                      "<br>Percent = ", ct_shp_map$percent, "%") # what the tooltip will show
      
      pall<-colorBin(c("#FFFFFF","#586F6B"), ct_shp_map$percent, 10, pretty = T) 
      
      map.leaf <- leaflet() %>% addPolygons(data = ct_shp_map$shape, fillColor = pall(ct_shp_map$percent),
                                            color = "#D7D9CE", # you need to use hex colors
                                            fillOpacity = 1, 
                                            weight = 1, 
                                            smoothFactor = 0.2, 
                                            popup = popup) %>%
        setMapWidgetStyle(list(background= "#292929")) %>%
        addLegend(pal = pall, opacity = 1,
                  values = ct_shp_map$percent, 
                  position = "bottomright", 
                  title = "Percent")
      
    } else {
      
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
    }
    
    
    if(input$county_overlay == "Yes"){
      map.leaf <- map.leaf %>% addPolygons(data = co_shp$shape, fillColor = "#B287A3",
                               color = "#000000", # you need to use hex colors
                               fillOpacity = 0.3, 
                               weight = 2, 
                               smoothFactor = 0.2)
    }
    
    if(input$title_create != ""){
      
      tag.map.title <- tags$style(HTML("
          .leaflet-control.map-title { 
          transform: translate(-50%,20%);
          position: fixed !important;
          left: 50%;
          text-align: center;
          padding-left: 10px; 
          padding-right: 10px; 
          background: rgba(255,255,255,0.75);
          font-weight: bold;
          font-size: 20px;
        }
        "))
      title <- tags$div(tag.map.title,HTML(input$title_create)) # title relating to the HTML code in the preamble
      
      map.leaf <- map.leaf %>% addControl(title, className="map-title")
    
      }
    
    return(map.leaf)
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
