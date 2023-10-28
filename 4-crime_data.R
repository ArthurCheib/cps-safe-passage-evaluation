## This code aims to retrieve three tipications of crime in Chicago from 2003 - 2022 ##

## Libraries
library(httr)
library(jsonlite)
library(here)
library(tidyverse)

## Creating main variables
CRIME_DATASET_ID <- "ijzp-q8t2"
YEAR_BEGIN <- 2013
YEAR_END <- 2018
ROW_MAX_NUM <- 400000

## Getting the data through the API endpoit
crime_vector <- c('theft', 'homicide', 'battery')
crime_vector <- crime_vector[1]

#my_token <- readline(prompt = 'Insert token: ')
#my_email <- readline(prompt = 'Insert email: ')
#my_password <- readline(prompt = 'Insert password: ')
MAP_ID <- "igwz-8jzy"

# Retrieve data from the City of Chicago Data Portal
get_chicago_portal_data <- function(dataset_id, file_name, query=NULL,
                                    api_token=NULL, username=NULL, password=NULL) {
  
  base_url <- "https://data.cityofchicago.org/resource/"
  
  # If there's a provided API token, authenticate
  if (!is.null(api_token)) {
    res <- GET(paste0(base_url, dataset_id, ".json"), 
               query = query,
               add_headers("X-App-Token" = api_token),
               authenticate(username, password))
  } else {
    res <- GET(paste0(base_url, dataset_id, ".json"), query = query)
  }
  
  df <- fromJSON(content(res, "text", encoding="UTF-8"), flatten = TRUE)
  
  return(df)
}

# Retrieving crime data separately by type to avoid ending with an excessively heavy csv file
store_crime_data <- function(crime_vector) {
  
  df_list <- list() # To store dataframes for each crime type
  
  for (crime in crime_vector) {
    
    CRIME <- toupper(crime)
    
    # Queries to only keep relevant columns, years, and types of crime
    query <- list(
      `$select` = "id,primary_type,community_area,year,latitude,longitude",
      `$where` = paste0("year >= ", YEAR_BEGIN,
                        " and year <= ", YEAR_END,
                        " and primary_type in ('", CRIME, "')",
                        " and latitude IS NOT NULL"),
      `$limit` = ROW_MAX_NUM
    )
    
    file_name <- paste0("crimes_", crime, "_raw.csv")
    df_list[[crime]] <- get_chicago_portal_data(
      CRIME_DATASET_ID, file_name, query = query,
      api_token = my_token, username = my_email, password = my_password)
  }
  
  return(df_list)
}

## Retrieving + saving the data
crime_data2 <- store_crime_data(crime_vector = crime_vector)
crime_data3 <- bind_rows(crime_data2)
write_csv(crime_data3, here('clean_data', 'crime_data.csv'))
