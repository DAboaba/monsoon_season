# load necessary packages for script
pacman::p_load(here, stringr, purrr, haven, magrittr, dplyr)

read_combine_dta_files <- function(dir_of_files, type) {
  full_dir_of_files <- here(dir_of_files)
  files_to_read <- str_subset(list.files(full_dir_of_files), type)
  df_all_files <- map_dfr(file.path(full_dir_of_files, files_to_read), read_dta)
}
