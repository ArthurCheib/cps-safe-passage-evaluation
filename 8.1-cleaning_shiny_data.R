## Treating the data for the shiny apps

## library
library(here)
library(tidyverse)

## Cleaning the data that will be used for the numeric boxes ##
dataset <- read_csv(here('clean_data', 'fixed_effects_data.csv')) %>% 
  rename(crime_distance = crime_school_distance) %>% 
  select(-control)

# Creating a fixed crime_distance
dataset2 <- dataset %>% 
  mutate(crime_distance = floor(crime_distance * 1.6 * 1000)) %>% 
  mutate(round_distance = case_when(crime_distance >= 0 & crime_distance <= 25 ~ '25m',
                                    crime_distance > 25 & crime_distance <= 50 ~ '50m',
                                    crime_distance > 50 & crime_distance <= 100 ~ '100m',
                                    crime_distance > 100 & crime_distance <= 200 ~ '200m',
                                    crime_distance > 200 & crime_distance <= 300 ~ '300m',
                                    crime_distance > 300 ~ '300m+')) %>% 
  mutate(round_distance = factor(round_distance, levels = c('25m', '50m', '100m', '200m', '300m', '300m+')))

# Grouping the data at the school level
dataset3 <- dataset2 %>% 
  group_by(year, round_distance, crime_type, school_id, treatment) %>% 
  summarize(avg_total_crimes = mean(n_distinct(crime_id), na.rm = TRUE),
            avg_school_attendance = mean(school_attendance)) %>% 
  ungroup() %>% 
  arrange(year, school_id, crime_type, round_distance)

## Saving this dataset, which will be the lighter input we can provide to shiny
write_csv(dataset3, here('clean_data', 'shiny_data.csv'))




## Cleaning the data that will be used for the numeric boxes ##
schools_db <- read_csv(here('clean_data', 'cps_schools_database.csv'))
crimes_db <- read_csv(here('clean_data', 'crime_data.csv')) %>% 
  select(id, latitude, longitude) %>% 
  setNames(c('crime_id', 'crime_lat', 'crime_long'))
  

data_leaflet <- read_csv(here('clean_data', 'fixed_effects_data.csv')) %>% 
  rename(crime_distance = crime_school_distance) %>% 
  select(-control)
