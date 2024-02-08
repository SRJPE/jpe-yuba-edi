library(dplyr)
library(readr)

append_historic_data <- function(historic_path, new_path){
  historic_data <- read_csv(historic_path)
  new_data <- read_csv(new_path)
  full_data <- bind_rows(historic_data, new_data)
  write.csv(full_data, new_path, row.names = FALSE)
}

historic_path <- sort(list.files("data/historic_data"))
full_historic_path <- paste0("data/historic_data/", historic_path)

new_data_path <- sort(list.files("data", pattern = "\\.csv$"))
full_new_data_path <- paste0("data/", new_data_path)

mapply(append_historic_data, full_historic_path, full_new_data_path)

