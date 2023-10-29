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

## Now, creating the datafarme that contains onlt those schools that:
# (1) - Where never before 2015
# (2) - Once inside the program (in 2015), remained there for 2016, 17 and 18
# Those fulfilling both conditions are within the treated group
df_final2 <- df_final %>% 
  as_tibble() %>% 
  pivot_wider(names_from = year, values_from = school_nam) %>% 
  setNames(janitor::make_clean_names(colnames(.))) %>% 
  ## Filterting for condition (1)
  filter(is.na(x2013) & is.na(x2014)) %>% 
  ## Filtering for conditions (2)
  filter(!is.na(x2015) & !is.na(x2016) & !is.na(x2017)) %>%
  ## Getting back to the relevant information only (id + name)
  select(1,5) %>% 
  rename('school_nam' = x2016)


## Saving the schools
write_csv(df_final2, here('clean_data', 'safe_passage_schools.csv'))
