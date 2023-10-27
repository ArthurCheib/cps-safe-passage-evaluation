## This code aims to download raw data from all schools in the Safe Passage Program ##

## Libraries
library(tidyverse)
library(RSocrata)
library(here)

## Getting the data through the API endpoit
my_token <- readline(prompt = 'Insert token: ')
my_email <- readline(prompt = 'Insert email: ')
my_password <- readline(prompt = 'Insert password: ')

## Queries that will be used
query <- "select the_geom, schoolid"
query_2014 <- "select the_geom, school_id"

## Dataset IDs
dataset_ID <- list(`2013` = 'rq9p-k3zy',
                   `2014` = 't8dp-yzqg',
                   `2015` = 'kvm8-tw23',
                   `2016` = '65ce-agii',
                   `2017` = 'v3t6-2wdk')

## Function to download all our data
get_dataset <- function(dic_year_code) {
  
  for(year in names(dic_year_code)) {
    id_temp <- dic_year_code[[year]]
    
    # Fetch raw data
    raw_temp <- read.socrata(paste0("https://data.cityofchicago.org/resource/", id_temp, ".json"),
                             app_token = my_token,
                             email = my_email,
                             password = my_password)
    
    # Save the raw data using `here`
    write_csv(raw_temp,
              here("raw_data", paste0('safepassage_', year, '.csv')))
  }
}

# Downloading the datasets
get_dataset(dic_year_code = dataset_ID)
