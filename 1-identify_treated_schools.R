## This code aims to create a table with all the schools in the Safe Passage Program (name + code) ##

## Packages
library(tidyverse)
library(here)

cps_treated_files <- list.files(here('raw_data'), pattern = 'safepassage')

# Initialize an empty dataframe 
df_final <- data.frame()

for (file in cps_treated_files) {
  
  # Read the file
  df_temp <- read_csv(here('raw_data', file))
  year <- str_extract(file, "\\d{4}")
  
  # For 2014, we need to rename the columns to standardize
  if (year == "2014") {
    df_temp <- df_temp %>% rename(school_nam = schoolname, schoolid = school_id)
  }
  
  # Extract columns containing 'school'
  cols <- colnames(df_temp)[str_detect(colnames(df_temp), 'school')]
  
  # Create a temporary dataframe with the selected columns and year
  df_year <- df_temp %>% 
    select(all_of(cols)) %>% 
    mutate(year = year)
  
  df_final <- bind_rows(df_final, df_year)
  
}

write_csv(df_final, here('clean_data', 'safe_passage_schools.csv'))
