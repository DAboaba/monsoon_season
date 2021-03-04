## Monsoon Season: Exploring Rainfall and Temperature Trends during India's Monsoon Season

![](https://tarnmoor.files.wordpress.com/2020/01/picnorteyucatan.jpg)

### *Explanation*
The code in this repository formed part of my application for a research position. I was asked to clean and explore a large
dataset (millions of observations across five variables) of rainfall and temperature readings from the Indian Meteorological Department. The dta files in the "raw_data/" directory beginning with rainfall_20 or temperature_20 consist of daily
rainfall or temperature grid-point data from 2009-2013. Rainfall readings are recorded in millimeters and temperature readings are recorded in degrees celsius. Each grid point came from a 1◦(latitude)  by  1◦(longitude) grid covering the Indian subcontinent.

Beyond the original task, I have updated this code repository to include an/a

  1. **exploratory data analysis exercise** where I explore the behavior of rainfall and temperature during the monsoon season
  2. **prediction exercise** where I attempt to predict the daily temperature during monsoon season
  3. **causal inference exercise** where I build an econometric model to estimate the monsoon season's impact on Indian district-level mortality


##### Data Cleaning - collapsing a grid-level dataset into a district-level dataset.

I was given an algorithm to match each grid point to district centroids within one of five Indian states. The algorithm  to  match  each  grid  point  to  a  district  was  as  follows:

  1. Take  a  weighted  average  of  daily  mean temperature and  daily  mean  rainfall (daily total rainfall) for  all  grid  points  within  100  KM  of
  each district’s  geographic  centroid.
      - The  weights  are  the  inverse  of  the  squared  distance  from  the  district's center.
      - The raw_data/district crosswalk small.dta file contains data on the coordinates of all district centroids for the five Indian
      states.
      - The final product from this section should be a district-level daily dataset from 2009-2013 with temperature, rainfall, and total rainfall variables.

#### *Exploratory Data Analysis*

**The primary sub-task of the exploratory data analysis step involved using the district-level dataset from the previous step to isolate the behavior of rainfall and temperature during the monsoon season in various districts.**

To explore temperature and rainfall behavior during the monsoon season, I
  (1) created plots of rainfall and temperature
  (2) based on my understanding of the monsoon season as a season of large increases in rainfall, used visible spikes in rainfall to
  identify the monsoon season's likely start and end-dates
  (3) highlighted the behavior of rainfall and temperature during the monsoon season.

Specifically, for each district and state, I

  1. Created interactive plots illustrating mean daily rainfall and temperature over the 5 year period
  2. Created interactive plots illustrating monthly average mean daily rainfall and temperature over the 5 year period
  3. Created a plot illustrating average mean daily rainfall and temperature for each day of a typical year
  4. Created a plot illustrating average monthly average mean daily rainfall and temperature for each month of a typical year


### *Modeling*

**The primary sub-tasks of the modeling step involved predicting season temperature and building econometric models to study the impact of the monsoon season.**

#### Prediction

#### Causal Inference
