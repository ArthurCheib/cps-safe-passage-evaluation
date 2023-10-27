## This code aims to create a database containing main info for all CPS schools ##

## Libraries
library(tidyverse)
library(here)

## Identifiers of the datasets
identifiers <- list(
  `2013` = 'dgq3-i7xm',
  `2014` = 'mntu-576c',
  `2015` = 'mb74-gx3g',
  `2016` = '75e5-35kf',
  `2017` = 'd2h8-2upd')

## Quick function to get data from the API
get_cdp_data <- function(identifier) {
  url <- sprintf("https://data.cityofchicago.org/resource/%s.csv", identifier)
  df <- read.csv(url, stringsAsFactors = FALSE)
  return(df)
}

# Function to process the data
process_data <- function(year, identifier) {
  
  ## Get the data
  df <- get_cdp_data(identifier)
  
  ## If it's the first identifier, then store the column names
  if (identifier == 'dgq3-i7xm') {
    colnames_list <- colnames(select(df, -c(the_geom, sch_addr, grade_cat)))
  }
  
  ## Set the data into standards depending on the year
  if (identifier %in% c('dgq3-i7xm', 'mntu-576c')) {
    
    df <- df %>% 
      select(-c(the_geom, sch_addr, grade_cat))
    
  } else if (identifier == 'mb74-gx3g') {
    
    df <- df %>% 
      select(-c(the_geom, address, zip, governance, grade_cat, phone,
                geo_network, commarea, ward_15, ald_15))
    
    df <- df %>% select(2, 1, 6, 5, 4, 3)
    colnames(df) <- colnames_list
    
  } else if (identifier == 'd2h8-2upd') {
    
    df <- df %>% 
      select(-c(the_geom, address, zip, governance, grade_cat, phone,
                geo_network, commarea, ward_15, ald_15))
    
    df <- df %>% select(1, 3, 4, 2, 6, 5)
    colnames(df) <- colnames_list
    
  } else {
    
    df <- df %>% 
      select(-c(the_geom, address, zip, governance, grade_cat, phone,
                geo_network, commarea, ward_15, ald_15))
    
    df <- df %>% select(2, 1, 4, 3, 6, 5)
    colnames(df) <- colnames_list
    
  }
  
  ## Outcome
  df <- df %>% 
    mutate(year = year)
  
  return(df)
}

# Applying the function to each identifier (=table) + saving the output
cps_database <- map2_df(names(identifiers), identifiers, process_data) 
write_csv(cps_database, here('clean_data', 'cps_database.csv'))
