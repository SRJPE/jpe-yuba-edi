library(tidyverse)
library(readxl)
library(googleCloudStorageR)


# clean -------------------------------------------------------------------
# notes
# encoding for not applicable is not standard across columns (release table). kept as is to match CAMP encodings
# kept in run, totalLength, markCode (recapture table) even though are NA

# pull historic data
gcs_auth(json_file = Sys.getenv("GCS_AUTH_FILE"))
gcs_global_bucket(bucket = Sys.getenv("GCS_DEFAULT_BUCKET"))

# Mark-Recapture Data for RST - none for historic yuba
# standard release data table - none for historic yuba


# RST Monitoring Data
# standard rst catch data table
gcs_get_object(object_name = "standard-format-data/standard_rst_catch.csv",
               bucket = gcs_get_global_bucket(),
               saveToDisk = "data-raw/standard_catch.csv",
               overwrite = TRUE)
standard_catch <- read_csv("data-raw/standard_catch.csv") |>
  filter(stream == "yuba river")

catch_format <- standard_catch |>
  mutate(site = str_to_title(site),
         subsite = case_when(subsite == "yub" ~ "Yuba River",
                             subsite == "hal" ~ "Hallwood 1 RR",
                             subsite == "hal2" ~ "Hallwood 2 RL",
                             subsite == "hal3" ~ "Hallwood 3"),
         species = "Chinook salmon",
         run = str_to_sentence(run),
         adipose_clipped = ifelse(adipose_clipped == T, "Hatchery", "Natural"),
         lifestage = str_to_sentence(lifestage),
         lifestage = ifelse(lifestage == "Yolk sac fry", "Yolk sac fry (alevin)", lifestage)) |>
  rename(visitTime = date,
         siteName = site,
         subSiteName = subsite,
         commonName = species,
         fishOrigin = adipose_clipped,
         lifeStage = lifestage,
         forkLength = fork_length,
         n = count) |>
  select(-c(stream, dead,interpolated,run_method,weight, is_yearling))

# standard environmental covariate data collected during RST monitoring
gcs_get_object(object_name = "standard-format-data/standard_RST_environmental.csv",
               bucket = gcs_get_global_bucket(),
               saveToDisk = "data-raw/standard_environmental.csv",
               overwrite = TRUE)
standard_environmental <- read_csv("data-raw/standard_environmental.csv") |>
  filter(stream == "yuba river")

environmental_format <- standard_environmental |>
  pivot_wider(id_cols = c(date, stream, site, subsite), names_from = "parameter", values_from = "value", values_fn = mean) |>
  rename(visitTime = date)

# standard rst trap data table
gcs_get_object(object_name = "standard-format-data/standard_rst_trap.csv",
               bucket = gcs_get_global_bucket(),
               saveToDisk = "data-raw/standard_trap.csv",
               overwrite = TRUE)
standard_trap <- read_csv("data-raw/standard_trap.csv") |>
  filter(stream == "yuba river")

trap_format <- standard_trap |>
  left_join(environmental_format, by = c("trap_stop_date" = "visitTime", "stream", "site", "subsite")) |>
  mutate(visitTime = ymd_hms(paste0(trap_stop_date, " ", trap_stop_time)),
         visitType = str_to_sentence(visit_type),
         visitType = ifelse(visitType == "Start trapping", "Start trap & begin trapping", visitType),
         trapFunctioning = str_to_sentence(trap_functioning),
         fishProcessed = str_to_sentence(fish_processed),
         includeCatch = ifelse(include == T, "Yes", "No"),
         site = str_to_title(site),
         subsite = case_when(subsite == "yub" ~ "Yuba River",
                             subsite == "hal" ~ "Hallwood 1 RR",
                             subsite == "hal2" ~ "Hallwood 2 RL",
                             subsite == "hal3" ~ "Hallwood 3")) |>
  rename(siteName = site,
         subSiteName = subsite,
         rpmRevolutionsAtStart = rpms_start,
         rpmRevolutionsAtEnd = rpms_end,
         counterAtEnd = counter_end,
         waterTemp = temperature,
         waterVel = velocity) |>
  select(-c(trap_visit_id, stream, trap_visit_date, trap_visit_time, trap_start_date,
            trap_start_time, trap_stop_date, trap_stop_time, visit_type, trap_functioning,
            fish_processed, gear_type, in_thalweg, partial_sample, is_half_cone_configuration,
            depth_adjust, debris_volume, debris_level, counter_start, time, sample_period_revolutions,
            include, comments, waterVel))




# catch (2022-onward)
catch_recent <- read_xlsx(here::here("data-raw", "yuba_catch.xlsx")) |>
  # TODO check with Casey about removing this field - are they sure they don't want to include it
  #mutate(releaseID = as.character(releaseID)) |>
  bind_rows(catch_format)
min(catch_recent$visitTime)
max(catch_recent$visitTime)
# trap (2023-onward)
trap_recent <- read_xlsx(here::here("data-raw", "yuba_trap.xlsx")) |>
  # TODO ask Casey to take care of these data cleaning in queries
  filter(projectDescriptionID == 7) |>
  select(-c(discharge)) |>
  bind_rows(trap_format) |>
  glimpse()
min(trap_recent$visitTime)
max(trap_recent$visitTime)
# recaptures (2022-onward)
recaptures <- read_xlsx(here::here("data-raw", "yuba_recapture.xlsx")) |>
  glimpse()
min(recaptures$visitTime)
max(recaptures$visitTime)
# releases (2022-onward)
releases <- read_xlsx(here::here("data-raw", "yuba_release.xlsx")) |>
  # TODO ask Casey to remove the db place holder field
  filter(releaseID != 255) |>
  # TODO check with Casey about removing this field
  select(-c(releaseSubSite)) |>
  glimpse()
min(releases$releaseTime, na.rm =T)
max(releases$releaseTime, na.rm = T)
filter(releases, is.na(releaseTime))
# save --------------------------------------------------------------------
write.csv(catch_recent, here::here("data/historic_data", "yuba_catch.csv"), row.names = FALSE)
write.csv(trap_recent, here::here("data/historic_data", "yuba_trap.csv"), row.names = FALSE)
write.csv(recaptures, here::here("data/historic_data", "yuba_recapture.csv"), row.names = FALSE)
write.csv(releases, here::here("data/historic_data", "yuba_release.csv"), row.names = FALSE)

# read in clean -----------------------------------------------------------
read.csv(here::here("data/historic_data", "yuba_catch.csv")) |> glimpse()
read.csv(here::here("data/historic_data", "yuba_trap.csv")) |> glimpse()
read.csv(here::here("data/historic_data", "yuba_recapture.csv")) |> glimpse()
read.csv(here::here("data/historic_data", "yuba_release.csv")) |> glimpse()

