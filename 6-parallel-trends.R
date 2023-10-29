## This code plots the two parallel trends graphs - a soft assumption before we run our fixed effects regression ##

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

## Finding the control schools
df_control2 <- df_control %>% 
  filter(total_crimes >= lower_bound & upper_bound <= upper_bound) %>% 
  filter(treatment == 0) %>% 
  select(school_id, school_nm) %>%
  distinct()

## Saving control schools
write_csv(df_control2, here('clean_data', 'control_schools.csv'))

# Grouping and summarizing data
control_schools <- df_control2 %>% 
  pull(school_id)

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
parallel_plot <- df_crime_plot %>% 
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
       plot = parallel_plot, width = 12, height = 6)
