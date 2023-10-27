## This code calculates the distance from every crime point to every CPS school ##

## Libraries
library(here)
library(tidyverse)
library(pracma)

## Function to drop columns from a data frame
drop_columns <- function(df, keep_list) {
  df %>%
    select(all_of(keep_list))
}

# Function to convert degrees to radians
degrees_to_radians <- function(degrees) {
  radians <- degrees * (pi / 180)
  return(radians)
}

## Haversine formula to calculate geodistance
haver_dist <- function(latA, longA, latB, longB) {
  
  ## For details on the function
  # Math formula: https://www.vcalc.com/wiki/vCalc/Haversine+-+Distance
  
  # Earth radius in miles
  earth_miles <- 3963.19
  
  # Convert to radians
  lat_A <- degrees_to_radians(latA)
  long_A <- degrees_to_radians(longA)
  lat_B <- degrees_to_radians(latB)
  long_B <- degrees_to_radians(longB)
  
  # Applying the formula
  lat_diff <- lat_B - lat_A
  long_diff <- long_B - long_A
  
  result1 <- sin(lat_diff / 2)^2 + cos(lat_A) * cos(lat_B) * sin(long_diff / 2)^2
  result2 <- (2 * asin(sqrt(result1))) * earth_miles
  
  return(result2)
  
}

haver_dist(latA = df_crime$latitude_crime[1],
           longA = df_crime$longitude_crime[1],
           latB = schools$y[1],
           longB = schools$x[1])

## Opening the crime data
df_crime <- read.csv(here('clean_data', 'crime_data.csv'))

# Renaming columns
names(df_crime)[names(df_crime) == "latitude"] <- "latitude_crime"
names(df_crime)[names(df_crime) == "longitude"] <- "longitude_crime"

## Schools dataset
schools <- read.csv(here("clean_data", "cps_database.csv"))

# Computing the distance
distance_list <- list()

for(i in 1:nrow(schools)) {
  
  ## For every school - get the school lat/long
  lat_school <- schools$school_lat[i]
  long_school <- schools$school_long[i]
  
  ## For every crime - get the cimr lat/long and compute the distance for a given school i
  for(j in 1:nrow(df_crime)) {
    lat_crime <- df_crime$latitude_crime[j]
    long_crime <- df_crime$longitude_crime[j]
    distance <- haver_dist(latA = lat_school, longA = long_school, latB = lat_crime, longB = long_crime)
    
    ## Because we won't need more than a few yards (keep it onlt <500 yards, which is roughly 500m too)
    if(distance <= 0.5) {
      distance_list[[length(distance_list) + 1]] <- list(school_id = schools$school_id[i],
                                                         crime_id = df_crime$id[j], 
                                                         distance = distance)
    }
  }
}

