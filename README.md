# Rainfall and Temperature Trends during India's Monsoon Season

The code in this repository formed part of my application for a research position. I was asked to clean and explore a partially
cleaned large dataset, millions of observations across five variables, from  the  Indian  Meteorological  Department. The individual
datasets making up the larger dataset contained grid-point data on daily  rainfall/temperature from 2009-2013. Each grid  point
came  from  a  1◦(latitude)  by  1◦(longitude)  grid  covering  the  Indian subcontinent. 

## Data Cleaning 

**The primary sub-task of the data cleaning step involved collapsing the grid-level dataset into a district-level dataset.**

I was given an algorithim to match each grid point to a district and expected to operationalize that using my chosen coding
language. The algorithm  to  match  each  grid  point  to  a  district  was  as  follows:  
  
  1. Take  a  weighted  average  of  daily  mean temperature,  daily  mean  rainfall,  and  daily  total  rainfall  for  all  grid  points  within  100  KM  of  each district’s  geographic  center.  
      - The  weights  are  the  inverse  of  the  squared  distance  from  the  district's center.
      - A district crosswalk dataset had data on the district centroids for the five Indian states I was expected to focus on.       

To  determine  which  grid  points  lay  within  100  KM  of  each  district  center,  I  also had  to  calculate the  distance between  every  grid  point  and  every  centroid.  

## Data Exploration 

**The primary sub-task of the data exploration step involved using the district-level dataset from the previous step to document the monsoon season in various districts.**

To that end for each district and state, I

  1. Calculated average and total daily rainfall over the five-year period
  2. Calculated average daily temperature over the five-year period
  3. Estimated the monsoon season's start and end dates
  2. Concisely presented my findings from (1), (2), and (3) by creating publication-quality tables and graphs
