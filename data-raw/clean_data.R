library(tidyverse)
library(readxl)

# clean -------------------------------------------------------------------
# TODO historic catch and trap (added in historic-data branch, need to confirm with RMT)
# TODO keep mort in catch, recaptures? (remove)
# TODO there is a record in trap with ProjectDescriptionID == 2 (remove)
# TODO trap discharge, waterVel is all NA
# TODO units for water velocity?
# TODO run, totalLength, markCode are all NA for recaptures
# TODO trap begins in 2023
# TODO releases markedLifeStage, releaseSubSite all NA

# catch (2022-onward)
catch_recent <- read_xlsx(here::here("data-raw", "EDI Query - Catch Raw_2023.xlsx")) |>
  select(-c(mort)) |>
  glimpse()

# trap (2023-onward)
trap_recent <- read_xlsx(here::here("data-raw", "EDI Query- Trap Visit_2023.xlsx")) |>
  filter(projectDescriptionID == 7) |>
  select(-c(discharge)) |>
  glimpse()

# recaptures (2022-onward)
recaptures <- read_xlsx(here::here("data-raw", "EDI Query- Recaptures_2023.xlsx")) |>
  select(-c(mort, actualCountID)) |>
  glimpse()

# releases (2022-onward)
releases <- read_xlsx(here::here("data-raw", "EDI Query- Releases_2023.xlsx")) |>
  select(-c(releaseSubSite, markedLifeStage)) |>
  glimpse()

# save --------------------------------------------------------------------
write.csv(catch_recent, here::here("data", "yuba_catch_edi.csv"), row.names = FALSE)
write.csv(trap_recent, here::here("data", "yuba_trap_edi.csv"), row.names = FALSE)
write.csv(recaptures, here::here("data", "yuba_recapture_edi.csv"), row.names = FALSE)
write.csv(releases, here::here("data", "yuba_release_edi.csv"), row.names = FALSE)

# read in clean -----------------------------------------------------------
read.csv(here::here("data", "yuba_catch_edi.csv")) |> glimpse()
read.csv(here::here("data", "yuba_trap_edi.csv")) |> glimpse()
read.csv(here::here("data", "yuba_recapture_edi.csv")) |> glimpse()
read.csv(here::here("data", "yuba_release_edi.csv")) |> glimpse()

