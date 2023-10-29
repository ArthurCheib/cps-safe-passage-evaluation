## This code plots the two parallel trends graphs - a soft assumption before we run our fixed effects regression ##

## Libraries
library(tidyverse)
library(here)

## Schools dataset
schools <- read_csv(here('clean_data', 'cps_schools_database.csv'))

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

crime <- merge(crime, crimes[, c(1, 4)], by = "crime_id", all.x = TRUE)

df_crime <- df_schools_distance %>% 
  left_join(crimes, by = 'crime_id') %>%
  filter(distance < 0.25)

# Grouping and summarizing data
df_crime_plot <- df_crime %>%
  group_by(school_id, year, treatment) %>%
  summarise(total_crimes = n_distinct(crime_id)) %>%
  ungroup() %>%
  group_by(year, treatment) %>%
  summarise(avg_crime = mean(total_crimes)) %>%
  ungroup()

## Plotting the total average crime in the schools surrounding for: treated vs control schools
plot <- ggplot(df_crime, aes(x = year, y = avg_crime, color = as.factor(treatment), group = treatment)) +
  geom_line(aes(linetype = as.factor(treatment), shape = as.factor(treatment)), size = 1) +
  geom_point(size = 3) +
  scale_color_manual(values = c("1" = "green", "0" = "blue"), name = "Treatment") +
  labs(title = "Average Crimes in the School's surroundings - 0.25 miles radius",
       x = "Year", y = "Average Total of Crimes") +
  geom_vline(aes(xintercept = 2015), color = "red", linetype = "dashed") +
  theme_minimal()

# Show the plot
print(plot)

# Save the plot
ggsave(filename = here("images", "2-parallel-trends_crimes.png"), plot = plot, width = 12, height = 6)
