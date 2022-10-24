library(shiny)
library(tidyverse)
library(lubridate)

census_api_key <- read.table("census_api_key_hold.txt")[1, 1]


ui <- fluidPage(
  
  # Application title
  titlePanel("Mapping Vaccination Data"),
  
  # Sidebar  
  sidebarLayout(
    sidebarPanel(
      radioButtons("county_overlay", h6(strong("County Outlines?")), 
                  choices = c("Yes", "No"), selected = "No")
    
    ),
    
    # Show a plot
    mainPanel(
      leafletOutput(outputId = "state_map")
    )
)
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
