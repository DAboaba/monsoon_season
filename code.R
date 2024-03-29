# Preparatory steps
# (1) Download required data and store the temperature, rainfall, and crosswalk data in 3 seperate folders
# (2) Arrange the files in the temperature and rainfall folders by name in ascending order for instance the temperature folder should have 
#     the temperature_2009.dta file first, then the temperature 2010.dta file next
# (3) Load required packages for data cleaning and manipulation

library(haven)   # loading haven package for reading in .dta files
library(dplyr)   # load the dplyr package which comes with functions specifically made for data manipulation
library(gmt)     # load the gmt package in order to use geodist() function to calculate distances
library(tidyr)   # load the tidyr package in order to have access to the separate() and gather() functions 
                   # for converting the data to a more stata accessible format
library(ggplot2) # load the ggplot package for data visualization.
library(digest)   # load a package that gives extra functionality to ggplot2
library(sjPlot)  # load the sjPlot package for creating publication-ready tables 

# Question 2:Data Cleaning
## Reading in the data

#### Reading in the Crosswalk data
# (1) Set working directory to the location of the downloaded crosswalk data
# (2) Using the read_dta() function I read in the crosswalk data into a data frame called Crosswalk

Crosswalk <- read_dta("district_crosswalk_small.dta")

#### Reading in the Temperature data
# (1) Set working directory to the location of the downloaded temperature data
# (2) Using the read_dta() function I read in the temperature_2009 through temperature_2013 data
# (3) Using the rbind() function I bind the different data together

# Assuming data for different years is kept in seperate files, if (1) they are all in the correct working
# directory and (2) they are all arranged appropriately, using the number of the files as an index, this for loop 
  #(1) reads in the data for the first year into an appropriately named data frame
  #(2) binds or stacks the data for successive years by row
# This results in a data frame where data for 2009 comes first, then 2010 second, etc.

for( i in 1:length(list.files())){
  if (i == 1){
    Temperature <- read_dta(list.files()[i])
  }else{
    Temperature <- rbind(Temperature,read_dta(list.files()[i]))
  }
}

####Reading in the Rainfall data
# (1) Set working directory to the location of the downloaded temperature data
# (2) Using the read_dta() function I read in the district_crosswalk data and rainfall_2009 through rainfall_2013 data
# (3) Using the rbind() function I bind the different data together

# The explanation for this for loop is the same as for temperature (lines 31 to 35).

for( i in 1:length(list.files())){
  if (i == 1){
    Rainfall <- read_dta(list.files()[i])
  }else{
    Rainfall <- rbind(Rainfall,read_dta(list.files()[i]))
  }
}


## Data Manipulation
# (1) I remove unnecessary variables from crosswalk by using the select() function to select only necessary variables
Crosswalk <- select(Crosswalk, stname_iaa, distname_iaa, xaxis, yaxis)

# (2) To enable an inner_join of the data I use the arrange() and select() functions to arrange the  Rainfall data in order of year, month, and day.
## Ties in year are broken by month, and ties in month are then broken by day.
Rainfall <- arrange(Rainfall, year, month, day)
## I change the ordering of the variables to day, month, year, etc with date as the final column so that the data is easier to read 
Rainfall <- select(Rainfall, day, month, year, everything(), date)

# (3) To allow me to later assign appropriate dates I manipulate the Dates variable. Because both the temperature and rainfall are 
    # recorded for the same dates I do this only using the Dates variable in the Rainfall dataset.

## Given that the final dataset is on a daily basis, I capture only a single copy of each date using the the unique() function on 
## the Dates variable and assign the results to a Dates vector.
Dates <- unique(Rainfall$date)

## Because the format of the dates is counterintuitive (i.e. in Year, Month, Day format so the 2nd of January 2009 is recorded as 20090102), I use 
## the paste() and substr() functions to create a vector with the proper dates in Day, Month, Year format for instance the 1st of January 2009 
## becomes 01012009.
Dates_formatted <- paste(substr(Dates,7,8),substr(Dates,5,6),substr(Dates,1,4), sep = "")

## I delete the Dates vector containing the dates in their original format.
rm(Dates)

## I remove the now unnecessary date variable from the Rainfall dataset.
Rainfall$date <- NULL 

# (4) I repeat step (2) and the final part of step (3) (line 86) for the Temperature data
Temperature <- arrange(Temperature, year, month, day)
Temperature <- select(Temperature, day, month, year, date, everything())
Temperature$date <- NULL 

# (5) Using the inner_join() function, I perform an inner_join on the data 
## For observations across the two datasets that have identical day, month, year, latitude, and longitude values, the inner_join() function keeps 
## one set of the joining variables and all other variables from both datasets.
Rainfall_Temperature <- inner_join(Temperature, Rainfall, by = c("day", "month", "year", "latitude", "longitude"))
## The result of this join has the same number of observations as both the temperature and rainfall datasets suggesting that the inner join was successful.

# (6) To save computing power and clean my workspace I delete the excess data
rm(Rainfall, Temperature)

## Calculating Appropriate Weights
# (1) I first create an empty matrix called Dist_matrix to hold the distances between all grid points on all days and all districts.
## The size of the matrix is determined by using the number of rows of the Rainfall_Temperature dataset as the nunmber of rows for the new matrix and the 
## number of rows from the Crosswalk dataset as the number of columns for the new matrix.
Dist_matrix <- matrix(nrow = nrow(Rainfall_Temperature), ncol = nrow(Crosswalk)) 

# (2) I combine a for loop and the geodist() function to populate the matrix so that the position of each distance in the matrix indicates 
  # the grid point, and district it was calculated for. For instance the distance in the first row and second column of the matrix comes 
  # from calculating the distance between the first grid point (or first latitude and longitude pair in the dataset) and the second district.

## the for loop uses the number of columns of Dist_matrix as an index so it iterates through its columns.
## this is possible because the geodist() function is vectorized. So it calculates all values in an entire column by calculating the geodestic
## distance between all grid points for each day and each district.
for (i in 1:ncol(Dist_matrix)){
  Dist_matrix[,i] <- geodist(Rainfall_Temperature$latitude, Rainfall_Temperature$longitude, Crosswalk$yaxis[i], Crosswalk$xaxis[i])
} 

# (3) I construct the weight matrix which holds the appropriate weighting between all grid points and all districts

#(A) I perform a logical test to see which elements are less than or equal to 100km, this returns a matrix with TRUE for distances where the condition 
# is met and FALSE elsewhere
Weight_matrix <- Dist_matrix <= 100 #I save this matrix in a container called weight_matrix

#(B) I divide the weight_matrix by the Dist_matrix and square the result. Because 
#     (i) when mathematical operations are performed on a logical object TRUE is coerced to 1 and FALSE is coerced to 0
#     (ii) the operation is done element-wise 
#    it gives the correct weight as detailed in the stata instructions. Grid points within a 100km have a weight that is the inverse of their 
#    squared distance, and grid points outside this distance have a weight of 0.
Weight_matrix <- (Weight_matrix/Dist_matrix)^2 #create weight matrix by dividing each element of matrix with square of corresponding element in the distance matrix 

## Creating Matrices to hold measures of average and total rainfall
# (1) I create matrices to hold measures of average and total rainfall
#   The unit of observation will be districts so I use the number of rows in Crosswalk (which is the number of districts) as the number of rows for these matrices
#   The columns will hold measures for each day thus the number of columns should be the total number of days across all years. This is easily calculated as 
#     roughly 366 (the maximum number of possible days in the year) multipled by the number of files in the working directory 
#       (which should equal the number of years for which data is recorded if the data is arranged as suggested at the beggining of this script)

# I assign the empty matrix of correct size to an appropriately named matrix
Avg_Rainfall_per_day <- matrix(nrow = nrow(Crosswalk), ncol = 366 * length(list.files()))

# The matrix holding Total Rainfall dats should be the same size as that holding Average Rainfall data so I assign a copy of the empty matrix of correct size
#  to the appropriately named Tot_Rainfall_per_day matrix
Tot_Rainfall_per_day <- Avg_Rainfall_per_day

# (2) I create two empty numeric vectors to hold the temporary values that the for loop below will generate
temp1 <- vector("numeric")
temp2 <- temp1

# (3) The for loop below calculates the weighted average of daily mean rainfall and the weighted average of daily total rainfall for all grid points within 100KM
#    of each district's geographic center.


# (A) I count the number of gridpoints for a particular day by 
  # (1) filtering the Rainfall_Temperatue dataset for a specific date
  # (2) and counting the observations by taking the number of rows of the Rainfall_Temperature dataset this gives the number of grid points for eac day)
num_gridpoints_day <- (nrow(filter(Rainfall_Temperature, day == "01", month == "01", year == "2009"))) 

# (B) Because the for loop is quite long I explain each line

for (i in 1:ncol(Weight_matrix)){ #The loop is made of two for loops, the first iterates through the column of the weight matrix (where each column holds the weights between a specific district and all the grid points on all the days)
  for (j in 1:nrow(Weight_matrix)){ #The second for loop iterates through the rows of the weight matrix (where each row holds the weights between a specific grid point on a specific day and the different districts)
    if (Weight_matrix[j,i] == 0 | is.na(Rainfall_Temperature$rainfall[j]) == T){ #For district i, if the jth grid point is outside 100km (shown by a value of 0 for the element of the weight matrix in the jth row and ith column) or if it has a missing value for rainfall I move to the next row (i.e. the next grid point for a specific day)
      j = j + 1
    }else{ #If the previous condition is unmet, 
      temp1[i] <- Rainfall_Temperature$rainfall[j] # I add the value of rainfall for the jth grid point on a particular day as the ith element of the temp1 vector
      temp2[i] <- Weight_matrix[j,i] # I add the appropriate weight (the weight based on the distance between the jth grid point on a particular day and the ith district) as the ith element of the temp2 vector
    }
    if (j %% num_gridpoints_day == 0){ #When all the grid points for a particular day have been taken into account, calculated by ensuring the current(jth) grid point is a multiple of the number of gridpoints for a particular day (i.e the remainder of j/num_grid_points is 0),
      Avg_Rainfall_per_day[i, (j/num_gridpoints_day)] <- weighted.mean(temp1, temp2) # take the temp1 and temp2 vectors containing the relevant rainfall values and the appropriate weights and calculate the weighted mean. This value is stored in the ith row and (j/number of grid points per day)th column of the Avg_Rainfall_per_day dataset
      Tot_Rainfall_per_day[i, (j/num_gridpoints_day)] <- sum(temp1*temp2*length(temp2)/sum(temp2)) # take the temp1 and temp2 vectors and calculate the weighted sum (which is the sum of all rainfall values multiplied by their correct weight and multiplied by a rescaling factor(the inverse of the mean of the weights)). 
      #I calculated this by reading stata documentation to find out how the weighted sum is found when the collapse function is used. This value is stored in the ith row and (j/number of grid points per day)th column of the Tot_Rainfall_per_day dataset
    }
  }
}

# For Avg_Rainfall_per day this results in a data frame with the average rainfall for the first district on the second day in the element at row 1, column 2. 

# (4) I convert both matrices to data frames
Avg_Rainfall_per_day <- data.frame(Avg_Rainfall_per_day)
Tot_Rainfall_per_day <- data.frame(Tot_Rainfall_per_day)

# (5) I assign the correctly formated dates in Dates_formatted as the variable names of the newly created data frames
  # The prefix Rainfall or TotRainfall is appended to the front of these dates for the Avg_Rainfall_per_day and Tot_Rainfall_per_day data franes respectively
names(Avg_Rainfall_per_day) <- paste("Rainfall", Dates_formatted, sep = "_")
names(Tot_Rainfall_per_day) <- paste("TotRainfall", Dates_formatted, sep = "_")

# (6) To save computing power and clean my workspace I delete the excess data
rm(temp1,temp2)

#Because the number of columns was created by assuming that every year had 366 days the data frames contain empty columns.
# (7) To deal wih this I use the duplicated(), starts_with(), and select() functions. The
#   duplicated function returns duplicated column names in thus case several instances of NA since these columns were not named
#     when combined with ! duplicated returns the non-duplicated column names
#   the select and starts_with functions select all the columns that start with the correct name which was created in step (4)
Avg_Rainfall_per_day <- select(Avg_Rainfall_per_day[,!duplicated(names(Avg_Rainfall_per_day))], starts_with("Rainfall"))
Tot_Rainfall_per_day <- select(Tot_Rainfall_per_day[,!duplicated(names(Tot_Rainfall_per_day))], starts_with("TotRainfall"))


## Creating Matrices to hold measures of average temperature
# (1) I repeat steps (1) to (7) for average rainfall for average temperature

Avg_Temperature_per_day <- matrix(nrow = nrow(Crosswalk), ncol = 366 * length(list.files()))

temp1 <- vector("numeric")
temp2 <- temp1

# this for loop calculates the weighted average of daily temperature for all grid points within 100KM of each district's geographic
# center in the same way as step (3) of Creating Matrices to hold measures of average and total rainfall. The only difference is the
# omission of lines 148 and 168 because I did not need to calculate the weighted average of daily total temperature for relevant grid
# points
for (i in 1:ncol(Weight_matrix)){
  for (j in 1:nrow(Weight_matrix)){
    if (Weight_matrix[j,i] == 0 | is.na(Rainfall_Temperature$temperature[j]) == T){
      j = j + 1
    }else{
      temp1[i] <- Rainfall_Temperature$temperature[j]
      temp2[i] <- Weight_matrix[j,i]
    }
    if (j %% num_gridpoints_day == 0){
      Avg_Temperature_per_day[i, (j/num_gridpoints_day)] <- weighted.mean(temp1, temp2)
    }
  }
}

Avg_Temperature_per_day <- data.frame(Avg_Temperature_per_day)
names(Avg_Temperature_per_day) <- paste("Temperature", Dates_formatted, sep = "_")
Avg_Temperature_per_day <- select(Avg_Temperature_per_day[,!duplicated(names(Avg_Temperature_per_day))], starts_with("Temperature"))


## Creating district_level_ dataset
# TO create the full district level data I
# (1) take the stname_iaa and distname_iaa variables from the crosswalk dataset, rename them to state and district respectively and assign
#    them to a new dataset called distruct_level_data
district_level_data <- select(Crosswalk, state = stname_iaa, district = distname_iaa)

# (2) bind the district_level_data to the Avg_Temperature_per_day, Avg_Rainfall_per_day, and Tot_Rainfall_per_day datasets
#    the result is a dataset with 75 rows and over 5000 columns where the observations are districts and the columns are the average temperature, rainfall
#    total rainfall for a particular day. For instance, the value in the first row and first column is the average temperature on 1st january 2009
#    for the first district()
district_level_data <- cbind(district_level_data, Avg_Temperature_per_day, Avg_Rainfall_per_day, Tot_Rainfall_per_day)

# (3) To save computing power and clean my workspace I delete the excess data
rm(Crosswalk, Rainfall_Temperature, Avg_Rainfall_per_day, Tot_Rainfall_per_day, Avg_Temperature_per_day,Weight_matrix, temp1, temp2, i, j)

## Converting data to a more stata accessible format
# After finishing data manipulation and aggregation to make the data stata-accesible and more human-readable I
# (1) Used the gather function to gather all the columns apart from state and district into one of two columns
#    the first called Date contained the relevant column names 
#    the second called Value contained the value for that column and district
district_level_data <- gather(district_level_data, Date, Value, -c(state,district))

# (2) Used the arrange() function to make sure that data was arranged in terms of state and district
district_level_data <- arrange(district_level_data,state,district)

# (3) Used the separate() function to split the Date variable(which contained column names) into Variable and Date columns
district_level_data <- separate(district_level_data, Date, c("Variable", "Date"))

# (4) Used the filter() function to create 3 datastets with only Temperature, Rainfall, and TotRainfall data respectively
Temperature <- filter(district_level_data, Variable == "Temperature")
Rainfall <- filter(district_level_data, Variable == "Rainfall")
TotRainfall <- filter(district_level_data, Variable == "TotRainfall")

# (5) Used the select() function to select and rename the value variable to reflect the relevant variable for each of the 3 datasets
#  In addition for the Temperature dataset, I also selected the state, district, and Date variables which are identical in the other 2
#   datasets.
Temperature <- select(Temperature, state, district, Date, "Temperature" = Value)
Rainfall <- select(Rainfall, "Rainfall" = Value)
TotRainfall <- select(TotRainfall, "TotRainfall" = Value)

# (6) Used the cbind() function to combine these datasets to form a dataset that shows for each district and day the relevant
#     Temperature, Rainfall, Total Rainfall
district_data_final <- cbind(Temperature, Rainfall, TotRainfall)

# (7) To save computing power and clean my workspace I delete the excess data
rm(Temperature, Rainfall, TotRainfall)

## Exporting the dataset 
# (1) I specify the information for how and where I would like to export the district data, where 
#  the first entry specifies the naming pattern for the exported file
#  the second entry specifies the directory where the file will be exported to (the Results directory)
#  the third entry specifies the type of the file
tmp <- tempfile(pattern = "district_data", tmpdir = "\\\\ad.ucl.ac.uk/homea/uctpoma/DesktopSettings/Desktop/EPIC", fileext = ".dta")

# (2) I use the write_dta() function to export district_data_final using the pre-specified export info
write_dta(district_data_final, tmp)


# Question 3:Data Exploration
## I use the filter and select functions on the district dataset to create a dataset for Canannore
Cannanore <- filter(district_data_final, district == "cannanore")
Ajmer <- filter(district_data_final, district == "ajmer")

## Part 1: Creating a five-year average of daily rainfall for Cannanore and Ajmer
## I use the mean() function to take the average of all Rainfall values for all days for Cannanore and Ajmer
mean(Cannanore$Rainfall)
mean(Ajmer$Rainfall)

## Part 2, 3, 4: Creating a scatterplot of rainfall by day for Cannanore and Ajmer, and identifying when the monsoon season starts and ends in each district
# (1) I correctly format the dates for plotting so that R recognizes the information in the Date column as dates for both datasets
Cannanore$Date <- c(as.Date.character(Cannanore$Date, format = "%d%m%Y"))
Ajmer$Date <- c(as.Date.character(Ajmer$Date, format = "%d%m%Y"))

# (2 & 3) I create a scatterpot of the required data for both districts
# To identify when the Monsoon season starts I combine R's default plot() and identify() functions. After running the two commands for one Cannanore I click on the points just at the beggining of each peak in rainfall and then the points at the end of each peak in rainfall
plot(x = Cannanore$Date, y = Cannanore$Rainfall)
identify(x = Cannanore$Date, y = Cannanore$Rainfall)

#For Monsoon start dates this returns the approximate observation indexes of the 5 Monsoon start dates and 5 Monsoon end dates
# This suggests that on average the Monsoon season in Cannanore starts on the 3rd of June and ends on the 9th of October in 2009. 
# I indicate these data points for all years in the plot below by 
# (1) filtering for and saving the data for the start dates and end dates as Cannanore_start and Cannanore_end respectively
Cannanore_start <- filter(Cannanore, Date == "2009-06-03"| Date == "2010-06-03"| Date == "2011-06-03" | Date == "2012-06-03" | Date == "2013-03-22")
Cannanore_end <- filter(Cannanore, Date == "2009-10-09"| Date == "2010-10-09"| Date == "2011-10-09" | Date == "2012-10-09" | Date == "2013-10-209")
  
# (2) plotting and highlighting this data with blue markers for Monsoon start dates and red markers for Monsoon end dates 
ggplot(Cannanore, aes(x = Date, y = Rainfall)) + geom_point(data = Cannanore) + geom_point(data = Cannanore_start, color = "blue") + geom_point(data = Cannanore_end, color = "red") + xlab("Date") + ylab("Amount of Rainfall(mm)") + ggtitle("Scatterplot of Rainfall by Day in Cannanore over Five Years") + labs(caption = "Monsoon start and end dates in Blue and Red respectively") + theme_minimal() + theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(face = "bold", size = "12"), axis.text.y = element_text(face = "bold", size = "12"))

# (3) I export the created scatterplot to an appropriately named pdf file

ggsave(filename = "Cannanore.pdf", device = "pdf", path = "\\\\ad.ucl.ac.uk/homea/uctpoma/DesktopSettings/Desktop/EPIC")

#I repeat (2&3) above for Ajmer's most visibe rainfall season (that in 2010)
plot(x = Ajmer$Date, y = Ajmer$Rainfall)
identify(x = Ajmer$Date, y = Ajmer$Rainfall)

# This suggests that on average the Monsoon season in Ajmer starts on the 22nd of June 2010 and ends on the 29th of September in 2010.
# I indicate these data points for all years in the plot below by
# (1) saving the data for the start dates and end dates as Ajmer_start and Ajmer_end respectively
Ajmer_start <- filter(Ajmer, Date == "2009-06-22"| Date == "2010-06-22"| Date == "2011-06-22" | Date == "2012-06-22" | Date == "2013-06-22")
Ajmer_end <- filter(Ajmer, Date == "2009-09-29"| Date == "2010-09-29"| Date == "2011-09-29" | Date == "2012-09-29" | Date == "2013-09-29")

# (2) plotting and highlighting this data with blue markers for Monsoon start dates and red markers for Monsoon end dates   
ggplot(Ajmer, aes(x = Date, y = Rainfall)) + geom_point(data = Ajmer) + geom_point(data = Ajmer_start, color = "blue") + geom_point(data = Ajmer_end, color = "red") + xlab("Date") + ylab("Amount of Rainfall(mm)") + ggtitle("Scatterplot of Rainfall by Day in Ajmer over Five Years") + labs(caption = "Monsoon start and end dates in Blue and Red respectively") + theme_minimal() + theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(face = "bold", size = "12"), axis.text.y = element_text(face = "bold", size = "12"))

# (4) I export the created scatterplot to an appropriately named pdf file
ggsave(filename = "Ajmer.pdf", device = "pdf", path = "\\\\ad.ucl.ac.uk/homea/uctpoma/DesktopSettings/Desktop/EPIC")

## Part 5: Create a publication-quality table of annual average temperature by state and Year
# (1) Set working directory to the location where you want to save the table


# (2) I use the substr() function to create a Year variable within district_data_final which contains the appropriate Year for each observation
## for instance 2009 is taken from 01012009.
district_data_final$Year <- substr(district_data_final$Date,5,8)

# (3) I take the district_data_final then I group it by State and Year and then I summarise the relevant Temperature values to get the mean temperature
## Note, the %>% symbol is read as then
Annual_Avg_Temperature <- district_data_final %>%group_by(state,Year)%>%summarise(Temperature = mean(Temperature))

# (4) To get the data in the proper format, I use the spread() function to turn the Year values into separate columns and specify the value as Temperature 
Annual_Avg_Temperature <- spread(Annual_Avg_Temperature, key = Year, value = Temperature)

# (2) To get the Temperature values to display only to the second decimal place
Annual_Avg_Temperature$`2009` <- sprintf("%.2f",Annual_Avg_Temperature$`2009`)
Annual_Avg_Temperature$`2010` <- sprintf("%.2f",Annual_Avg_Temperature$`2010`)
Annual_Avg_Temperature$`2011` <- sprintf("%.2f",Annual_Avg_Temperature$`2011`)
Annual_Avg_Temperature$`2012` <- sprintf("%.2f",Annual_Avg_Temperature$`2012`)
Annual_Avg_Temperature$`2013` <- sprintf("%.2f",Annual_Avg_Temperature$`2013`)


# (6) Finally, using the tab_df() function I export the data frame as a word document with the appropriate title, column headers, 
tab_df(Annual_Avg_Temperature, title = "Annual Average Temperature by State and Year", col.header = c("State", "Year", "Temperature"), alternate.rows = TRUE, file = "Annual_AvgTemp_Table.doc")



