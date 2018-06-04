# Practical-Demonstration-of-RA-Abilities

The code attached is a practical demonstration of my coding competency. It formed part of my application for a Research position. As part of the application I was asked to work on a large dataset of  partially  cleaned  temperature and  rainfall  readings  from  the  Indian  Meteorological  Department.  The datasets consisted of daily  rainfall  and  temperature  grid  point  data  from 2009-2013. Each grid  point  came  from  a  1◦(latitude)  x  1◦(longitude)  grid  covering  the  Indian  subcontinent. When correctly combined the full rainfall and temperature datasets each had over a million observations across five variables. 

The assessment was divided into a **CLEANING** and **EXPLORATION** stage. 

_Cleaning stage_

**The central task of the cleaning stage was to  collapse  the  grid-level  dataset  into  a  district-level  dataset.**

I was given an algorithim to match each grid point to a district and expected to operationalize that using a coding language I chose. The algorithm  to  match  each  grid  point  to  a  district  was  as  follows:  
  
  1. Take  a  weighted  average  of  daily  mean temperature,  daily  mean  rainfall,  and  daily  total  rainfall  for  all        grid  points  within  100  KM  of  each district’s  geographic  center.  
      - The  weights  are  the  inverse  of  the  squared  distance  from  the  district's center.
      - A district crosswalk dataset had data on the district centroids for the five Indian states I was expected to focus on.       
  2.  To  determine  which  grid  points  lay  within  100  KM  of  each  district  center,  I  had  to  calculate the  distance between  every  grid  point  and  every  centroid.  
 
**The  final  product  from  this  section  was  a  district-level  daily  dataset  from  2009-2013  with  temperature,rainfall,  and  total  rainfall  variables.**

I was also expected to address the following questions with as much specificity as possible:

  1. How  would  your  code  scale  up  with  this  larger  dataset?  
  2. Would you  need  any  additional  computing  resources?  

_Exploration stage_

**The central task of the exploration stage was to use the district-level daily dataset I had just created to document the monsoon season in various districts.**

For two specific districts I created: 
  1. a  five-year  average  of  daily  rainfall.
  2. a  scatterplot  of  rainfall  by  day.  

Using this I was able to estimate when
  1. the monsoon  season  started in thesse districts 
  2. the monsoon season ended in these districts  
 
Lastly, I indicated this information on two publication-quality graphs and created a publication-quality table of annual average temparature by state and year. 
