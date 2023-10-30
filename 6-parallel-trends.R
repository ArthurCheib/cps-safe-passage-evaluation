## This code plots the two parallel trends graphs - a soft assumption before we run our fixed effects regression ##

#### CRIME PLOT ####

## Libraries
library(tidyverse)
library(here)

## Loading the database of schools + creating the treatment status column
safe_passage_schools <- read_csv(here('clean_data', 'safe_passage_schools.csv')) %>% 
  pull(schoolid)

schools <- read_csv(here('clean_data', 'cps_schools_database.csv')) %>% 
  mutate(treatment = if_else(school_id %in% safe_passage_schools, 1, 0))

## Crime dataset
datasets <- c("crimes_battery_raw.csv", "crimes_homicide_raw.csv", "crimes_theft_raw.csv")
crimes_list <- list()

for(data in datasets) {
  df <- read_csv(here("raw_data", data))
  crimes_list[[length(crimes_list) + 1]] <- df
}

# Combining all data frames in the list into a single data frame
crimes <- bind_rows(crimes_list)

# Renaming the first column
colnames(crimes)[1] <- "crime_id"

## Crime vs schools dataset ###
crime_distance <- read_csv(here("clean_data", "crime_schools_distance.csv"))

## Merging the data
df_schools_distance <- crime_distance %>% 
  left_join(schools, by = 'school_id')

df_crime <- df_schools_distance %>% 
  left_join(crimes %>% 
              select(c(crime_id, primary_type, year)),
            by = "crime_id") %>% 
  filter(distance < 0.25) %>% 
  select(crime_id, primary_type, year, distance, school_id, treatment, school_nm) %>% 
  ## We only need 2yrs before and 2yrs after implementation (we can skip 2018)
  filter(year != 2018)

## Powering the concept of control group
# Schools not in the program, but in areas with 'similar' levels of crimes
# Similar levels in the years prior to the intervention (2013, 2014, 2015)
df_control <- df_crime %>%
  group_by(school_id, school_nm, year, treatment) %>%
  summarise(total_crimes = n_distinct(crime_id)) %>%
  ungroup() %>% 
  filter(!year %in% c(2015, 2016, 2017)) %>% 
  ## outliers (but 99% likelihood of being wrongly inputed data)
  filter(total_crimes <= 1000)

## Lower and Upper bounds
lower_bound <- mean(df_control$total_crimes) - 0.5 * sd(df_control$total_crimes)
upper_bound <- mean(df_control$total_crimes) + 2 * sd(df_control$total_crimes)


## Polishing control schools
control <- read_csv(here('clean_data', 'control.csv')) %>% 
  pull(SCHOOLID)

# Finding the control schools
df_control2 <- df_control %>% 
  filter(total_crimes >= lower_bound & upper_bound <= upper_bound) %>% 
  filter(treatment == 0) %>% 
  select(school_id, school_nm) %>%
  distinct() %>% 
  filter(school_id %in% control) 

control_schools <- df_control2 %>%
  pull(school_id)

## Saving control schools
write_csv(df_control2, here('clean_data', 'control_schools.csv'))

# Grouping and summarizing data
df_crime_plot <- df_crime %>%
  filter(treatment == 1 | school_id %in% control_schools) %>% 
  mutate(control = if_else(treatment == 0, 1, 0)) %>% 
  group_by(school_id, year, treatment) %>%
  summarise(total_crimes = n_distinct(crime_id)) %>%
  ungroup() %>%
  group_by(year, treatment) %>%
  summarise(avg_crime = mean(total_crimes)) %>%
  ungroup()

## Plotting the total average crime in the schools surrounding for: treated vs control schools
parallel_plot_crime <- df_crime_plot %>% 
  ggplot(aes(x = year, y = avg_crime, color = as.factor(treatment), group = treatment)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  scale_color_manual(values = c("1" = "dodgerblue", "0" = "grey"), 
                     name = "Group",
                     breaks = c("0", "1"),
                     labels = c("Control", "Treated")) +
  labs(title = "Average Crimes in the School's surroundings - 0.25 miles radius",
       subtitle = "Parallel trend's - Fixed Effects Assumption",
       x = "",
       y = "Total of Crimes",
       caption = 'Source: Chicago Data Portal 2013 - 2018') +
  geom_vline(aes(xintercept = 2015), color = "red", linetype = "dashed", size = 1) +
  theme_light() +
  theme(legend.position="bottom", 
        title = element_text(size = 16))

# Save the plot
ggsave(filename = here("images", "2-parallel-trends_crimes.png"),
       plot = parallel_plot_crime, width = 12, height = 6)





#### ATTENDANCE PLOT ####
## Attendance dataset
## Filtering the dataset
# 1) no pre-k nor elementary
# 2) 2013 <> 2017 for year
# 3) Average for each school, not each grade
df_attendance <- read.csv(here::here("clean_data", "cps_attendance.csv")) %>% 
  as_tibble() %>% 
  setNames(janitor::make_clean_names(colnames(.))) %>%
  pivot_longer(cols = str_c('x', c(2003:2019, 2021, 2022)),
               names_to = 'year',
               values_to = 'attendance') %>% 
  mutate(year = as.numeric(str_remove(year, 'x'))) %>% 
  filter(school_name != 'CITYWIDE',
         year >= 2013, year <= 2017) %>% 
  ## Moment to select which grades to filter for
  filter(grade %in% as.character(c(7,8,9,10,11,12))) %>% 
  filter(!is.na(attendance)) %>%
  select(-c(network, group))

df_attendance2 <- df_attendance %>% 
  group_by(school_id, school_name, year) %>%
  summarise(avg_attendance = mean(attendance, na.rm = TRUE)) %>% 
  ungroup() %>% 
## Adding the control + treatment info
  mutate(treatment = if_else(school_id %in% safe_passage_schools, 1, 0)) %>% 
  filter(treatment == 1 | school_id %in% control_schools) %>%
## Filtering out schools with no data for some years
  pivot_wider(names_from = year, values_from = avg_attendance) %>% 
  setNames(janitor::make_clean_names(colnames(.))) %>% 
  filter(!is.na(x2013) & !is.na(x2014) & !is.na(x2015) & !is.na(x2016) & !is.na(x2017)) %>% 
  pivot_longer(cols = str_c('x', c(2013:2017)),
               names_to = 'year', 
               values_to = 'avg_attendance') %>% 
  mutate(year = as.numeric(str_remove(year, 'x')))

## Plotting the attendance
parallel_plot_attendance <- df_attendance2 %>% 
  group_by(year, treatment) %>%
  summarise(avg_attendance_rt = mean(avg_attendance, na.rm = TRUE))


# Plotting the total average attendance rate for treated vs control schools
attendance_plot <- parallel_plot_attendance %>% 
  ggplot(aes(x = year, y = avg_attendance_rt,
             color = as.factor(treatment),
             group = treatment)) +
  geom_line(size = 1) +
  geom_point(size = 3) +
  scale_color_manual(values = c("1" = "dodgerblue", "0" = "grey"), 
                     name = "Treatment",
                     breaks = c("0", "1"),
                     labels = c("Control", "Treated")) +
  labs(title = "Attendance Rate accross CPS - 2013 to 2018",
       x = "",
       y = "Average Attendance Rate",
       caption = 'Source: Chicago Data Portal 2013 - 2018') +
  geom_vline(aes(xintercept = 2015), color = "red", linetype = "dashed", size = 1.15) +
  theme_light() +
  theme(legend.position = "bottom")

attendance_plot

# Save the plot
ggsave(filename = here::here("images", "3-parallel-trends_attendance.png"),
       plot = attendance_plot, width = 12, height = 6)


## Misc
# Since most of the work was done here > let's create the dataset for FE reg right here!
df_attendance_fe <- df_attendance %>% 
  group_by(school_id, school_name, year) %>%
  summarise(avg_attendance = mean(attendance, na.rm = TRUE)) %>% 
  ungroup() %>% 
  ## Adding the control + treatment info
  mutate(treatment = if_else(school_id %in% safe_passage_schools, 1, 0)) %>% 
  filter(treatment == 1 | school_id %in% control_schools) %>% 
  select(school_id, year, avg_attendance)

df_fe <- df_crime %>%
  filter(treatment == 1 | school_id %in% control_schools) %>% 
  mutate(control = if_else(treatment == 0, 1, 0)) %>% 
  select(1,2,3,4,5,7,6,8) %>% 
  arrange(school_id, year) %>% 
  left_join(df_attendance_fe, by = c('school_id', 'year')) %>% 
  select(1,2,4,3,5,6,7,8,9) %>% 
  setNames(c('crime_id', 'crime_type', 'crime_school_distance', 'year',
             'school_id', 'school_name', 'treatment', 'control', 'school_attendance'))

## Saving the regression fe dataset
write_csv(df_fe, here('clean_data', 'fixed_effects_data.csv'))
  
