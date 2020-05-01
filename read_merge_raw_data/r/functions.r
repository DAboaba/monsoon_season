# load necessary packages for script
pacman::p_load(here, stringr, purrr, haven, magrittr, dplyr)

# check the existence of a directory and if it isn't found, create it
check_create_dir <- function(dir_path){
  if (!dir.exists(dir_path)){
    dir.create(dir_path)
  }
}

#task_setup <- function(task_dir){
  
#}

# The rainfall and temperature data are split between 5 files for each year between 2009 and 2013. The following function takes
# advantage of this dataset structure to
#   (1) read in the different datasets
#   (2) stack them by year
#   (3) arrange rows 
# in an efficient manner:

read_combine_dta_files <- function(dir_of_files = "raw_data", type){
  full_dir_of_files <- here(dir_of_files)
  files_to_read <- str_subset(list.files(full_dir_of_files), type)
  df_all_files <- map_dfr(file.path(full_dir_of_files, files_to_read), read_dta)
  df_all_files %<>% 
    dplyr::arrange(latitude, longitude, year, month, day) %>% 
    select(-c(date))
  return(df_all_files)
}
