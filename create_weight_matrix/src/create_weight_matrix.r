# load necessary packages for task
pacman::p_load(here, yaml, feather, renv, geodist, readr)

# restore the project's local library state from renv.lock
renv::restore(confirm = FALSE)

# specify task directory
task_dir <- here("create_weight_matrix")

# load task specific function 
source(file.path(task_dir, "r", "functions.r"))

# check and/or create task output directory
task_input_dir <- file.path(task_dir, "input")
task_output_dir <- file.path(task_dir, "output")
check_create_dir(task_output_dir)

# read in a config file specifying unique decisions made for this task
task_config <- yaml::read_yaml(file.path(task_dir, "hand/config.yaml"))

# read in the rain_temp and crosswalk files
rain_temp <- read_feather(file.path(task_input_dir, "rain_temp.feather"))
crosswalk <- read_feather(file.path(task_input_dir, "crosswalk.feather"))

# use geodist to automatically 
#   detects the latitude and longitude columns in rain_temp and crosswalk   
#   calculates the distance in metres for pairs of gridpoint (from rain_temp) and district (from crosswalk) 

dist <- geodist(rain_temp, crosswalk)

# convert the distances to kilometres
dist <- dist/1000

# considering the above, dist should have the same number of rows as rain_temp and the same number of columns as crosswalk's rows
stopifnot(nrow(dist) == nrow(rain_temp), ncol(dist) == nrow(crosswalk))

# create a logical matrix that indicates which elements of dict are equal to or less than 100 km and thus come from a grid point
# and district pair that are within 100 km of each other
dist_logical <- dist <= 100 

# take advantage of coercion (logical data is coerced to numeric by making TRUE = 1 & FALSE = 0) to create a matrix containing appropriate weights for grid-point and district pairs within 100 km of each other and 0 for grid-point and district pairs outside this distance
weight <- (dist_logical/dist)^2 

# write results of task to appropriate directory
write_rds(dist, file.path(task_output_dir, "dist.rds"))
write_rds(weight, file.path(task_output_dir, "weights.rds"))

#delete uneccessary objects
rm(rain_temp, crosswalk, dist, dist_logical, weight)

# symlink input directory of clean_data task to output directory 
file.symlink(from = task_output_dir, to = file.path(here(task_config$next_task), "input"))

