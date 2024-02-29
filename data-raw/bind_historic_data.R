library(dplyr)
library(readr)

append_historic_data <- function(historic_path, new_path){
  historic_data <- readr::read_csv(historic_path)
  new_data <- readr::read_csv(new_path)
  edi_data_without_duplicates <- setdiff(new_data, historic_data) #find all rows in edi_yuba that are not in historic_yuba
  # data_without_duplicates <- bind_rows(historic_yuba, edi_data_without_duplicates)
  full_data <- dplyr::bind_rows(historic_data, edi_data_without_duplicates)
  write.csv(full_data, new_path, row.names = FALSE)
}

historic_path <- sort(list.files("data/historic_data"))
full_historic_path <- paste0("data/historic_data/", historic_path)

new_data_path <- sort(list.files("data", pattern = "\\.csv$"))
full_new_data_path <- paste0("data/", new_data_path)

mapply(append_historic_data, full_historic_path, full_new_data_path)

# edi_yuba <- read_csv("data-raw/yuba_trap.csv")
# historic_yuba <- read_csv("data/historic_data/yuba_trap.csv")
# edi_data_without_duplicates <- setdiff(edi_yuba, historic_yuba) #find all rows in edi_yuba that are not in historic_yuba
# data_without_duplicates <- bind_rows(historic_yuba, edi_data_without_duplicates)
#
# write.csv(data_without_duplicates, "data-raw/test_release.csv", row.names = FALSE)
