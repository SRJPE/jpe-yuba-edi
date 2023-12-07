library(EMLaide)
library(tidyverse)
library(readxl)
library(EML)

datatable_metadata <-
  dplyr::tibble(filepath = c("data/yuba_catch.csv",
                             "data/yuba_recapture.csv",
                             "data/yuba_release.csv",
                             "data/yuba_trap.csv"),
                attribute_info = c("data-raw/metadata/yuba_catch_metadata.xlsx",
                                   "data-raw/metadata/yuba_recapture_metadata.xlsx",
                                   "data-raw/metadata/yuba_release_metadata.xlsx",
                                   "data-raw/metadata/yuba_trap_metadata.xlsx"),
                datatable_description = c("Daily catch",
                                          "Recaptured catch",
                                          "Release trial",
                                          "Daily trap operations"),
                datatable_url = paste0("https://raw.githubusercontent.com/SRJPE/jpe-yuba-edi/main/data/",
                                       c("yuba_catch.csv",
                                         "yuba_recapture.csv",
                                         "yuba_release.csv",
                                         "yuba_trap.csv")))
# save cleaned data to `data/`
excel_path <- "data-raw/metadata/yuba_metadata.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/metadata/abstract.docx"
methods_docx <- "data-raw/metadata/methods.md"
#methods_docx <- "data-raw/metadata/methods.md" # use md for bulleted formatting. I don't believe lists are allowed in methods (https://edirepository.org/news/news-20210430.00)

#edi_number <- reserve_edi_id(user_id = Sys.getenv("edi_user_id"), Sys.getenv("edi_password"))
edi_number <- "edi.1529.2" # reserved 11-8-2023

dataset <- list() %>%
  add_pub_date() %>%
  add_title(metadata$title) %>%
  add_personnel(metadata$personnel) %>%
  add_keyword_set(metadata$keyword_set) %>%
  add_abstract(abstract_docx) %>%
  add_license(metadata$license) %>%
  add_method(methods_docx) %>%
  add_maintenance(metadata$maintenance) %>%
  add_project(metadata$funding) %>%
  add_coverage(metadata$coverage, metadata$taxonomic_coverage) %>%
  add_datatable(datatable_metadata)

# GO through and check on all units
custom_units <- data.frame(id = c("number of rotations", "NTU", "revolutions per minute", "number of fish", "days"),
                           unitType = c("dimensionless", "dimensionless", "dimensionless", "dimensionless", "dimensionless"),
                           parentSI = c(NA, NA, NA, NA, NA),
                           multiplierToSI = c(NA, NA, NA, NA, NA),
                           description = c("number of rotations",
                                           "nephelometric turbidity units, common unit for measuring turbidity",
                                           "number of revolutions per minute",
                                           "number of fish counted",
                                           "number of days"))


unitList <- EML::set_unitList(custom_units)

eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset,
            additionalMetadata = list(metadata = list(unitList = unitList))
)

EML::write_eml(eml, paste0(edi_number, ".xml"))
EML::eml_validate(paste0(edi_number, ".xml"))

EMLaide::evaluate_edi_package(Sys.getenv("EDI_USER_ID"), Sys.getenv("EDI_PASSWORD"), paste0(edi_number, ".xml"))
#
# EMLaide::update_edi_package(user_id = Sys.getenv("EDI_USER_ID"),
#                             password = Sys.getenv("EDI_PASSWORD"),
#                             eml_file_path = paste0(getwd(), "/", edi_number, ".xml"),
#                             existing_package_identifier = paste0("edi.1529.1.xml"),
#                             environment = "production")

# The code below is for updating the eml number and will need to be implemented when
# we move to automated updates
# doc <- read_xml(paste0(edi_number, ".xml"))
# edi_number<- data.frame(edi_number = doc %>% xml_attr("packageId"))
# update_number <- edi_number %>%
#   separate(edi_number, c("edi","package","version"), "\\.") %>%
#   mutate(version = as.numeric(version) + 1)
# edi_number <- paste0(update_number$edi, ".", update_number$package, ".", update_number$version)

# preview_coverage <- function(dataset) {
#   coords <- dataset$coverage$geographicCoverage$boundingCoordinates
#   north <- coords$northBoundingCoordinate
#   south <- coords$southBoundingCoordinate
#   east <- coords$eastBoundingCoordinate
#   west <- coords$westBoundingCoordinate
#
#   leaflet::leaflet() |>
#     leaflet::addTiles() |>
#     leaflet::addRectangles(
#       lng1 = west, lat1 = south,
#       lng2 = east, lat2 = north,
#       fillColor = "blue"
#     )
# }
#
# preview_coverage(dataset)
