library(dplyr)
library(readr)

append_historic_data <- function(historic_path, new_path){
  historic_data <- readr::read_csv(historic_path)
  if (new_path == "data/yuba_catch.csv"){
    new_data <- readr::read_csv(new_path) |>
      filter(ProjectDescriptionID == 7)
  }else{
    new_data <- readr::read_csv(new_path) |>
      filter(projectDescriptionID == 7)
  }
  full_data <- dplyr::bind_rows(historic_data, new_data)
  write.csv(full_data, new_path, row.names = FALSE)
}

path <- sort(c("yuba_catch.csv", "yuba_trap.csv"))
full_historic_path <- paste0("data/historic_data/", path)
full_new_data_path <- paste0("data/", path)

mapply(append_historic_data, full_historic_path, full_new_data_path)

