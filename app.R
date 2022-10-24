library(shiny)
library(tidyverse)
library(lubridate)

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
    mainPanel()
)
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
