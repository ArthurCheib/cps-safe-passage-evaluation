## This code runs our fixed effects regression ##

## Libraries
library(tidyverse)
library(here)
library(plm)
library(lmtest)

## Loading the data + transformation to run the fe model
data_fe <- read_csv(here('clean_data', 'fixed_effects_data.csv'))

fe <- data_fe %>% 
  filter(crime_school_distance <= 0.100) %>% 
  group_by(school_id, year, treatment) %>% 
  summarize(total_crime = n_distinct(crime_id),
            attendance_rate = mean(school_attendance, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(policy_year = 2015) %>%
  mutate(safe_passage = if_else(year >= policy_year & treatment == 1, 'Yes', 'No')) %>% 
  select(-treatment) %>%  
  select(1,2,3,6,5,4) %>% 
  arrange(desc(school_id)) %>% 
  filter(!is.na(attendance_rate))

# Checking how crime and being a school in a treated area are related
panel_lm1 <- plm(formula = total_crime ~ safe_passage,
                 data = fe,
                 model = 'within',
                 index = c('year', 'school_id'),
                 effect = 'twoways')

coeftest(panel_lm1, vcov. = vcovHC, type = "HC1")

# Checking how attendance and being a school in a treated area are related
panel_lm2 <- plm(formula = attendance_rate ~ safe_passage,
                 data = fe,
                 model = 'within',
                 index = c('year', 'school_id'),
                 effect = 'twoways')

coeftest(panel_lm2, vcov. = vcovHC, type = "HC1")
