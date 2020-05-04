# load necessary packages for task
pacman::p_load(here, yaml, haven, dplyr, feather, renv)

# restore the project's local library state from renv.lock
renv::restore(confirm = FALSE)

# specify task directory
task_dir <- here("read_merge_raw_data")

# load task specific function 
source(file.path(task_dir, "r", "functions.r"))

# check and/or create task output directory
task_output_dir <- file.path(task_dir, "output")
check_create_dir(task_output_dir)

# read in a config file specifying unique decisions made for this task
task_config <- yaml::read_yaml(file.path(task_dir, "hand/config.yaml"))

# read in the raw_data files using the read_dta or read_combine_dta_files function
crosswalk <- haven::read_dta(here("raw_data", "district_crosswalk_small.dta"))
rain <- read_combine_dta_files(type = "rainfall") 
temp <- read_combine_dta_files(type = "temperature")

# i want to join the rain and temp datasets together using the columns they both possess while ensuring that all rows from both 
# (even those that don't have a corresponidng row in the other dataset) are returned
rain_temp <- full_join(rain, temp, by = task_config$columns_to_join_by) 

# since all rows of rain have a corresponding row in temp, the result of this join should have the same number of observations as both the rain and temp datasets
stopifnot(nrow(rain_temp) == nrow(rain), nrow(rain_temp) == nrow(temp))

#delete redundant objects
rm(rain, temp)

# write results of task to appropriate directory
feather::write_feather(rain_temp, file.path(task_output_dir, "rain_temp.feather"))
feather::write_feather(crosswalk, file.path(task_output_dir, "crosswalk.feather"))

# symlink input directory of clean_data task to output directory 
file.symlink(from = task_output_dir, to = file.path(here(task_config$next_task), "input"))

