## This code aims to create a file with student's attendance for all CPS schools  from 2006-2021 ##

## Libraries
library(tidyverse)
library(here)
library(httr)
library(janitor)

attendance_url <- "https://www.cps.edu/globalassets/cps-pages/about-cps/district-data/metrics/metrics_attendance_2022.xlsx"

## Retrieve attendance data from the CPS webpage
get_attendance_data <- function(url, year_begin = NA, year_end = NA) {
  
  response <- httr::GET(url)
  file_name <- "school_attendance_raw.xlsx"
  writeBin(httr::content(response, "raw"), here("raw_data", file_name))
  df <- readxl::read_xlsx(here("raw_data", file_name), sheet="Overtime")
  
  return(df)
  
}

## Function to group education levels since we will analyze attendance in each one separately:
make_level <- function(grade) {
  case_when(
    grade == "Pre-K" ~ "Pre-K",
    grade %in% c("K", "1", "2", "3", "4", "5") ~ "Elementary school",
    grade %in% c("6", "7", "8") ~ "Middle school",
    grade %in% c("9", "10", "11", "12") ~ "High school",
    TRUE ~ "Grade not determined")
}

## Retrieving the data and cleaning it
cps_attendance <- get_attendance_data(attendance_url,
                                      year_begin = 2006,
                                      year_end = 2021) %>% 
  # Exclude city-wide averages and school average + other cleanings
  filter(`School Name` != "CITYWIDE" & Group != "All (Excludes Pre-K)") %>% 
  setNames(make_clean_names(colnames(.))) %>%
  pivot_longer(cols = str_c('x', c(2003:2019, 2021, 2022)),
               names_to = "year",
               values_to = "attendance_rate") %>%
  mutate(year = as.numeric(str_remove(year, 'x')),
         grade2 = make_level(grade)) %>% 
  select(school_id:grade, grade2, everything(.))

## Saving attendance output
write_csv(cps_attendance, here('clean_data', 'cps_attendance.csv'))

