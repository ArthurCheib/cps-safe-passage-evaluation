## Libraries
library(here)
library(tidyverse)
library(leaflet)

## Data
data <- read_csv(here('clean_data', 'shiny_data.csv'))
data_leaflet <- read_csv(here('clean_data', 'leaflet_data.csv'))

## SHINY SERVER ##
server <- function(input, output) {
  
  ## Creating a reactive dataset based on user input (for boxes)
  reactive_data <- reactive({
    filtered_data <- data %>%
      ## Implementing the first filter (year)
      filter(year == input$year,
             ## Implementing the second filter (crime distance)
             round_distance == input$crime_distance)
    
    return(filtered_data)
    
  })
  
  ## Creating a reactive dataset based on user input (for the leaflet)
  reactive_data2 <- reactive({
    filtered_data <- data_leaflet %>%
      ## Implementing the first filter (year)
      filter(year == input$year,
             ## Implementing the second filter (crime distance)
             round_distance == input$crime_distance)
    
    return(filtered_data)
    
  })
  
  ## Computing values for the boxes
  
  ## CONTROL SCHOOLS ##
  
  ## Average Total Crime for Control Schools
  output$avg_total_crime_control <- renderText({
    
    df <- reactive_data() %>%
      filter(treatment == 0)
    
    ceiling(mean(df$avg_total_crimes, na.rm = TRUE))
    
  })
  
  ## Average Battery for Control Schools
  output$avg_battery_control <- renderText({
    
    df <- reactive_data() %>%
      filter(treatment == 0, crime_type == "BATTERY")
    
    ceiling(mean(df$avg_total_crimes, na.rm = TRUE))
    
  })
  
  ## Average Homicide for Control Schools
  output$avg_homicide_control <- renderText({
    df <- reactive_data() %>%
      filter(treatment == 0, crime_type == "HOMICIDE")
    
    ## Fixing the issue for NaN for homicides
    val <- ceiling(mean(df$avg_total_crimes, na.rm = TRUE))
    
    if(is.nan(val)) {
      
      val <- 0
    }
    
    return(val)
    
  })
  
  ## Average Theft for Control Schools
  output$avg_theft_control <- renderText({
    df <- reactive_data() %>%
      filter(treatment == 0, crime_type == "THEFT")
    
    ceiling(mean(df$avg_total_crimes, na.rm = TRUE))
    
  })
  
  # Average School Attendance for Control Schools
  output$avg_attendance_control <- renderText({
    
    df <- reactive_data() %>%
      filter(treatment == 0)
    
    ceiling(mean(df$avg_school_attendance, na.rm = TRUE))
    
  })
  
  
  ## TREATED SCHOOLS ##
  
  # Average Total Crime for Treated Schools
  output$avg_total_crime_treated <- renderText({
    df <- reactive_data() %>%
      filter(treatment == 1)
    
    ceiling(mean(df$avg_total_crimes, na.rm = TRUE))
    
  })
  
  # Average Battery for Treated Schools
  output$avg_battery_treated <- renderText({
    df <- reactive_data() %>%
      filter(treatment == 1, crime_type == "BATTERY")
    
    ceiling(mean(df$avg_total_crimes, na.rm = TRUE))
    
  })
  
  # Average Homicide for Treated Schools
  output$avg_homicide_treated <- renderText({
    df <- reactive_data() %>%
      filter(treatment == 1, crime_type == "HOMICIDE")
    
    ## Fixing the issue for NaN for homicides
    val <- ceiling(mean(df$avg_total_crimes, na.rm = TRUE))
    
    if(is.nan(val)) {
      
      val <- 0
    }
    
    return(val)
  
  })
  
  # Average Theft for Treated Schools
  output$avg_theft_treated <- renderText({
    
    df <- reactive_data() %>%
      filter(treatment == 1, crime_type == "THEFT")
    
    ceiling(mean(df$avg_total_crimes, na.rm = TRUE))
    
  })
  
  # Average School Attendance for Treated Schools
  output$avg_attendance_treated <- renderText({
    
    df <- reactive_data() %>% filter(treatment == 1)
    
    ceiling(mean(df$avg_school_attendance, na.rm = TRUE))
    
  })
  
  ## Adding the leaflet map
  output$map <- renderLeaflet({
    leaflet(reactive_data2()) %>%
      ## Light tile
      addTiles(urlTemplate = "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png") %>%
      
      # Adding Buffer for Treated schools
      addCircles(data = reactive_data2()[reactive_data2()$treatment == 1, ],
                 lng = ~school_long, lat = ~school_lat,
                 color = "transparent",
                 fillColor = "blue",
                 fillOpacity = 0.25,
                 weight = 0,
                 radius = 500) %>%
      
      # Adding Control schools with grey icon
      addMarkers(data = reactive_data2()[reactive_data2()$treatment == 0, ],
                 ~school_long, ~school_lat,
                 icon = icons(iconUrl = "www/grey-school-icon.png", iconHeight = 20, iconWidth = 20),
                 label = ~school_name) %>%
      
      # Adding Treated schools with blue icon
      addMarkers(data = reactive_data2()[reactive_data2()$treatment == 1, ],
                 ~school_long, ~school_lat,
                 icon = icons(iconUrl = "www/blue-school-icon.png", iconHeight = 20, iconWidth = 20),
                 label = ~school_name) %>%
      
      # Adding crimes
      addCircleMarkers(data = reactive_data2(),
                       ~crime_long, ~crime_lat,
                       color = "red",
                       label = ~crime_type,
                       radius = 3)
  })
  
}

