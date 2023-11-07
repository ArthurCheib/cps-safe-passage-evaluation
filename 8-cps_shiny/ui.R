## Packages
library(shiny)
library(dplyr)
library(ggplot2)

ui <- fluidPage(
  
  ## Setting the side bar size
  tags$style(type = "text/css", "
    .sidebar {
      width: 15%;
    }
  "),
  
  ## Setting up the header with 3 elements (img1 + title + img2)
  titlePanel(
    div(style = "display: flex; align-items: center; justify-content: space-between;",
        div(style = "flex: 1; text-align: left;",
            img(src="cps_logo.png", height = 80)),
        div(style = "flex: 2; text-align: center;",
            h3("Safe Passage Program Dashboard")),
        div(style = "flex: 1; text-align: right;",
            img(src="harris_logo.png", height = 50))
    )
  ),
  
  # Sidebar layout
  sidebarLayout(
    # Sidebar with controls
    sidebarPanel(
      selectInput("year",
                  "Select Year:",
                  choices = c(2013:2017)),
      selectInput("crime_distance",
                  "Select Crime Distance:",
                  choices = c("25m", "50m", "100m", "200m", "300m", "300m+"),
                  selected = "25m"),
    ),
    
    ## Main panel = 10 boxes (5 for each type of treatment variable)
    mainPanel(
      ## Control schools
      div(
        h3("Control Schools"),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #E0E0E0; border-radius: 10px; padding: 10px; text-align: center;margin-right: 2%;", 
                 "Avg Total Crime:", br(), tags$b(textOutput("avg_total_crime_control"))),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #E0E0E0; border-radius: 10px; padding: 10px; text-align: center; margin-right: 2%;", 
                 "Avg Battery:", br(), tags$b(textOutput("avg_battery_control"))),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #E0E0E0; border-radius: 10px; padding: 10px; text-align: center; margin-right: 2%;", 
                 "Avg Homicide:", br(), tags$b(textOutput("avg_homicide_control"))),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #E0E0E0; border-radius: 10px; padding: 10px; text-align: center; margin-right: 2%;", 
                 "Avg Theft:", br(), tags$b(textOutput("avg_theft_control"))),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #E0E0E0; border-radius: 10px; padding: 10px; text-align: center;", 
                 "Avg Attendance (%):", br(), tags$b(textOutput("avg_attendance_control")))
      ),
      
      ## Treated schools
      div(
        h3("Treated Schools"),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #00CED1; border-radius: 10px; padding: 10px; text-align: center; margin-right: 2%;", 
                 "Avg Total Crime:", br(), tags$b(textOutput("avg_total_crime_treated"))),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #00CED1; border-radius: 10px; padding: 10px; text-align: center; margin-right: 2%;", 
                 "Avg Battery:", br(), tags$b(textOutput("avg_battery_treated"))),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #00CED1; border-radius: 10px; padding: 10px; text-align: center; margin-right: 2%;", 
                 "Avg Homicide:", br(), tags$b(textOutput("avg_homicide_treated"))),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #00CED1; border-radius: 10px; padding: 10px; text-align: center; margin-right: 2%;", 
                 "Avg Theft:", br(), tags$b(textOutput("avg_theft_treated"))),
        
        tags$div(style="display: inline-block; width: 18%; background-color: #00CED1; border-radius: 10px; padding: 10px; text-align: center;", 
                 "Avg Attendance (%):", br(), tags$b(textOutput("avg_attendance_treated")))
      ),
      
      ## Adding our leaflet map
      leaflet::leafletOutput("map")
      
    )
  )
)


