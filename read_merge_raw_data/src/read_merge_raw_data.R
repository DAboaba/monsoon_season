# Ensure pacman is installed before attempting to use it ----
if (!require("pacman")) install.packages("pacman")
library(pacman)

# load necessary packages for task ----
pacman::p_load(here, yaml, haven, dplyr, feather)

# specify task directory ----
task_dir <- here("read_merge_raw_data")

# load general and/or task specific function ----
source(file.path("..", "R", "general_functions.R"))
source(file.path(task_dir, "R", "merging_functions.R"))

# check and/or create task output directory ----
task_output_dir <- file.path(task_dir, "output")
check_create_dir(task_output_dir)

# read in a config file specifying unique decisions made for this task ----
task_config <- yaml::read_yaml(file.path(task_dir, "hand/config.yaml"))

# read in the raw_data files using the read_dta or read_combine_dta_files function ----
full_crosswalk_path <- here(task_config$crosswalk_raw_path)
crosswalk <- haven::read_dta(full_crosswalk_path)
rain <- read_combine_dta_files(dir_of_files = task_config$raw_data_dir, type = "rainfall")
temp <- read_combine_dta_files(dir_of_files = task_config$raw_data_dir, type = "temperature")

# join the rain and temp datasets together using the columns they both possess ----
# while ensuring that all rows from both (even those that don't have a corresponidng row in the other dataset) are returned
rain_temp <- full_join(rain, temp, by = task_config$columns_to_join_by) %>%
  dplyr::arrange(latitude, longitude, year, month, day) %>%
  select(-c(starts_with("date")))

# since all rows of rain have a corresponding row in temp, the result of this join should have the same number of observations as both the rain and temp datasets
stopifnot(nrow(rain_temp) == nrow(rain), nrow(rain_temp) == nrow(temp))

# write results of task to appropriate directory ----
feather::write_feather(rain_temp, file.path(task_output_dir, "rain_temp.feather"))
feather::write_feather(crosswalk, file.path(task_output_dir, "crosswalk.feather"))

# delete unnecessary objects ----
rm(rain, temp, rain_temp, crosswalk)
