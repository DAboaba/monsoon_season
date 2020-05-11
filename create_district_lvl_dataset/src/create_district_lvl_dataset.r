# load necessary packages for task
pacman::p_load(here, yaml, feather, renv, geodist, readr, dplyr, magrittr)

# restore the project's local library state from renv.lock
renv::restore(confirm = FALSE)

# specify task directory
task_dir <- here("create_district_lvl_dataset")

# load task specific function 
source(file.path(task_dir, "r", "functions.r"))

# check and/or create task output directory
task_input_dir <- file.path(task_dir, "input")
task_output_dir <- file.path(task_dir, "output")
check_create_dir(task_output_dir)

# read in a config file specifying unique decisions made for this task
task_config <- yaml::read_yaml(file.path(task_dir, "hand/config.yaml"))

# read in the rain_temp, crosswalk, and weights files
rain_temp <- feather::read_feather(file.path(task_input_dir, "rain_temp.feather"))
crosswalk <- feather::read_feather(file.path(task_input_dir, "crosswalk.feather"))
weights <- read_rds(file.path(task_input_dir, "weights.rds")) 

# create a date variable
rain_temp %<>%
  mutate(date = lubridate::ymd(paste0(year,month,day))) 
  
# properly name each column of the wieghts matrix
district_names <- crosswalk$distname_iaa
colnames(weights) <- district_names
weights %<>% as_tibble()

rm(district_names)

# column bind the rain_temp matrix to the weights matrix to get a dataset that has the daily rainfall, daily temperature, and distance
# to each district for every observation (every grid point and date pair)

grid_daily_measures_weights <- bind_cols(rain_temp, weights) 

grid_district_lvl_daily_measures_weights <- grid_daily_measures_weights  %>%
  tidyr::pivot_longer(c(ahmedabad:udaipur), names_to = "district", values_to = "weight")

stopifnot(nrow(grid_district_lvl_daily_measures_weights) ==
            nrow(grid_daily_measures_weights) * (ncol(grid_daily_measures_weights) - 8))

district_lvl_daily_measures <- grid_district_lvl_daily_measures_weights %>%
  group_by(date, year, month, day, district) %>%
  summarise(mean.wei.rainfall = weighted.mean(rainfall, weight, na.rm = TRUE),
            total.wei.rainfall = sum(na.omit(rainfall * weight)), #not sure this formula is right
            mean.wei.temperature = weighted.mean(temperature, weight, na.rm = TRUE)) %>% 
  ungroup()

# write results of task to appropriate directory
feather::write_feather(grid_daily_measures_weights, file.path(task_output_dir, "grid_daily_measures_weights.feather"))
feather::write_feather(grid_district_lvl_daily_measures_weights, file.path(task_output_dir,
                                                                           "grid_district_lvl_daily_measures_weights.feather"))
feather::write_feather(district_lvl_daily_measures, file.path(task_output_dir, "district_lvl_daily_measuresfeather"))

#delete unnecessary objects
rm(rain_temp, crosswalk, weights, grid_daily_measures_weights, grid_district_lvl_daily_measures_weights,
   district_lvl_daily_measures)

# symlink input directory of clean_data task to output directory 
#file.symlink(from = task_output_dir, to = file.path(here(task_config$next_task), "input"))


