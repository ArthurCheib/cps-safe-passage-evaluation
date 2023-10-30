## This code calculates the distance from every crime point to every CPS school ##

## Libraries
library(here)
library(tidyverse)

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
  
  # Applying the formula
  lat_diff <- degrees_to_radians(latB) - degrees_to_radians(latA)
  long_diff <- degrees_to_radians(longB) - degrees_to_radians(longA)
  
  result1 <- sin(lat_diff / 2)^2 + cos(degrees_to_radians(latA)) * cos(degrees_to_radians(latB) ) * sin(long_diff / 2)^2
  result2 <- (2 * asin(sqrt(result1))) * earth_miles
  
  return(result2)
  
}

## Opening the crime data
df_crime <- read.csv(here('clean_data', 'crime_data.csv'))

# Renaming columns
names(df_crime)[names(df_crime) == "latitude"] <- "latitude_crime"
names(df_crime)[names(df_crime) == "longitude"] <- "longitude_crime"

## Schools dataset
schools <- read.csv(here("clean_data", "cps_schools_database.csv"))

## Using purr - we create a grid of all combinations of school and crime
grid <- expand.grid(i = 1:nrow(schools), j = 1:nrow(df_crime))

# map2_dfr to iterate over the grid
distance_df <- map2_dfr(grid$i, grid$j, ~{
  i <- .x
  j <- .y
  
  distance <- haver_dist(latA = schools$school_lat[i],
                         longA = schools$school_long[i],
                         latB = df_crime$latitude_crime[j],
                         longB = df_crime$longitude_crime[j])
  
  # Use an inline if condition to filter by distance
  if(distance <= 0.250) {
    
    return(data.frame(school_id = schools$school_id[i], 
                      crime_id = df_crime$id[j], 
                      distance = distance))
  } else {
    
    return(NULL)
  
  }
  
})

## Saving file
write_csv(distance_df, here('clean_data', 'crime_schools-distance.csv'))
