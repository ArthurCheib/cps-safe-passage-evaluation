---
editor_options: 
  markdown: 
    wrap: 72
---

# Evaluating the Chicago Public School's Safe Passage Program

## Data and Policy Summer Scholar Program - UChicago

### Capstone Project prepared by: Arthur Cheib

------------------------------------------------------------------------

## Research Design

**Main Objective:** estimate the impact of the **Safe Passage Program
(SPP)**, a policy introduced by the Chicago Public Schools. SPP is an
initiative to ensure the safety of students by providing a positive,
trusted adult presence on their ways to and back from their schools. We
will use two outcomes to evaluate the policy: - School attendance - The
volume of crime happening within the schools' surroundings

**Secondary Objective:** develop a Shiny app to visualize: -
Distribution of different types of crimes over time - Distribution and
focalization of the SPP

**Step-by-ste of the Analysis:** steps to estimate the effect of the SPP
in our outcomes of interest.

1. Gather data/metrics about:
- student' attendance to CPS
- major types of crimes in Chicago
- schools' participation in SPP

2.  Calculate the geographical distance from every crime in Chicago to
    every school
3.  Create graphs to see if the 'parallel trends' soft assumption holds
    for both our outcomes of interest
4.  Create an interactive app to learn about the SPP, visualize and
    explore crimes and their closeness to schools
5.  Analyze coefficients estimated of the program's impact on the
    outcomes through running fixed-effects model

------------------------------------------------------------------------

## Gathering and Transforming the Data

### School data

-   The first dataset obtained was concerning one variable of interest
    for our fixed effects models: **school's attendance**. The [script](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/3-school_attendance.R)
    downloads the dataset as an Excel file from the CPS website
    using an URL.

-   The second dataset contained information on demographics for all the
    schools that were part of CPS. The [script](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/2-cps_database.R) gets all its information from
    the [City of Chicago Data Portal](https://data.cityofchicago.org/)
    using an API (Socrata).

-   Finally, the third dataset on the school level had information about participation in the Safe Passage Program and the [script](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/1-identify_treated_schools.R) also use the Chicago Data Portal API to get the data. 

#### Control vs. Treated

After thorough data cleaning, a consolidated dataset was formed containing all pertinent details about the schools. Schools that participated in the SPP program continuously from 2013 to 2017 were defined as 'treated schools', while those that (i) did not participate during this entire duration, and (ii) had similar level of violence in the school's surrounding prior to the program intervention were labeled as 'control schools'

### Crimes in Chicago

Data was sourced from the City of Chicago Data Portal via its API, where each row in the dataset represented a specific crime, detailing its georeferenced location and type. Given the sheer volume of crimes (over a million during this period) and the impending computational challenges in calculating distances between crimes and schools, the [script](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/4-crime_data.R) narrows the search - and thus further analysis - to three main crime types: thefts, battery, and homicides. We fetched data for these crimes from 2013-2018 and combined them into a single dataset.

### Geodistance calculation

We calculated the geodistance between every crime (of the three types we were interested in - theft, battery, homicide) in Chicago from 2013-2017 using a [script](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/5-calculating_geodistance.R) that employs the Haversine formula for distance between latitude and longitude points. Though conceptually straightforward, this was computationally intensive, involving over 300 million calculations to identify crimes within a 0.25-mile radius of Chicago Public Schools. The resulting [table](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/clean_data/crime_schools_distance.csv) showcases the script's output.

------------------------------------------------------------------------

## Visualizing the Data

### Parallel Trends Assumption

This parallel trend assumption is necessary for the fixed effects
regression model because it ensures that the estimated coefficients are
unbiased by any time-varying variables that are not included in the
model. In the case of our model, results are fairly balanced for the
crime data but no parallel for the attendance rate. Thus, the estimated
coefficients accurately reflect the real relationships between the
independent and dependent variables in the case of crime data. Still,
less validity was found for the student attendance rate.

|                                                          PT - Crime data                                                           |                                                         PT - Attendance\*\*\*                                                          |
|:----------------------------------:|:----------------------------------:|
| ![](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/images/2-parallel-trends_crimes.png) | ![](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/images/3-parallel-trends_attendance.png) |

### Shiny Application

The Shiny app developed serves as an interactive visualization and analysis tool for understanding the relationship between schools and crime incidents in Chicago over a specified time period. At its core, the app presents data from Chicago's Safe Passage Program, focusing on delineating the differences between treated schools and control schools. Users can filter the data by year, and visualize crucial metrics such as average total crimes, battery incidents, homicides, thefts, and school attendance rates for both treated and control schools. Also, it has a leaflet map incorporated, pinning down the locations of schools and marking the crime incidents in proximity. The can be founde here:  [ui.R](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/8-cps_shiny/ui.R) and [server.R](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/8-cps_shiny/server.R) scripts.

## ![](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/images/shiny-app.png)

## Running and Fitting the Model (Results)

### Coefficients

In my analysis, I conducted two fixed-effects regressions. In the first - [script](https://github.com/ArthurCheib/cps-safe-passage-evaluation/blob/main/7-fixed_effects.R) - I used the total number of crimes within a 0.25-mile radius of a public school as the dependent variable, with the Safe Passage Program (SPP) policy's presence serving as the key independent variable. The second regression analyzed student attendance rates. Both models accounted for potential unobserved variables by implementing entity and time fixed effects, specifically controlling for 'school_id' and 'year'. Results indicated that program participation led to an average reduction of eight crimes (a 7.5% drop) around the school in the first year. Furthermore, schools in the program experienced a 1.9% boost in student attendance rates.
