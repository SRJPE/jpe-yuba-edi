library(tidyverse)
library(readxl)

# clean -------------------------------------------------------------------
# TODO historic catch and trap
# TODO keep mort in catch, recaptures?
# TODO there is a record in trap with ProjectDescriptionID == 2
# TODO trap discharge, waterVel is all NA
# TODO units for water velocity?
# TODO run, totalLength, markCode are all NA for recaptures
# TODO trap begins in 2023
# TODO releases markedLifeStage, releaseSubSite all NA

# catch (2022-onward)
catch_recent <- read_xlsx(here::here("data-raw", "EDI Query - Catch Raw_2023.xlsx")) |>
  glimpse()

# trap (2023-onward)
trap_recent <- read_xlsx(here::here("data-raw", "EDI Query- Trap Visit_2023.xlsx")) |>
  glimpse()

# recaptures (2022-onward)
recaptures <- read_xlsx(here::here("data-raw", "EDI Query- Recaptures_2023.xlsx")) |>
  glimpse()

# releases (2022-onward)
releases <- read_xlsx(here::here("data-raw", "EDI Query- Releases_2023.xlsx")) |>
  mutate(markedLifeStage = ifelse(markedLifeStage == "Not applicable (n/a)", NA, markedLifeStage)) |>
  glimpse()

# save --------------------------------------------------------------------
write.csv(catch_recent, here::here("data", "catch.csv"), row.names = FALSE)
write.csv(trap_recent, here::here("data", "trap.csv"), row.names = FALSE)
write.csv(recaptures, here::here("data", "recaptures.csv"), row.names = FALSE)
write.csv(releases, here::here("data", "releases.csv"), row.names = FALSE)

# read in clean -----------------------------------------------------------
read.csv(here::here("data", "catch.csv")) |> glimpse()
read.csv(here::here("data", "trap.csv")) |> glimpse()
read.csv(here::here("data", "recaptures.csv")) |> glimpse()
read.csv(here::here("data", "releases.csv")) |> glimpse()

