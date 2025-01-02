library(dplyr)
library(readr)
library(zip)

append_historic_data <- function(historic_path, new_path) {

  # Temporary directories for extraction and writing
  folder_path <- "data/yuba.zip"
  temp_dir <- tempdir()
  temp_dir <- normalizePath(temp_dir, winslash = "/")
  original_wd <- getwd()

  # Unzip new_path
  unzip(folder_path, exdir = temp_dir)
  new_file <- file.path(temp_dir, basename(new_path))

  # Load historic data
  historic_data <- readr::read_csv(historic_path)

  # Load and filter new data
  new_data <- if (grepl("yuba_catch.csv", new_path)) {
    readr::read_csv(new_file) |>
      filter(ProjectDescriptionID == 7)
  } else {
    readr::read_csv(new_file) |>
      filter(projectDescriptionID == 7)
  }

  # Combine data
  full_data <- dplyr::bind_rows(historic_data, new_data)

  # Write updated data back to the temporary directory
  write_csv(full_data, new_file)
  setwd(temp_dir)
  files_to_zip <- list.files(pattern = "^yuba", recursive = TRUE)

  zip(
    zipfile = file.path(original_wd, folder_path),
    files =  files_to_zip
    )
  setwd(original_wd)

}

# Paths for historical and new data
path <- sort(c("yuba_catch.csv", "yuba_trap.csv"))
full_historic_path <- paste0("data/historic_data/", path)
full_new_data_path <- paste0("data/yuba.zip/", path)

# Apply the function to all file pairs
mapply(append_historic_data, full_historic_path, full_new_data_path)
