# check the existence of a directory and if it isn't found, create it
check_create_dir <- function(dir_path) {
  if (!dir.exists(dir_path)) {
    dir.create(dir_path)
  }
}
