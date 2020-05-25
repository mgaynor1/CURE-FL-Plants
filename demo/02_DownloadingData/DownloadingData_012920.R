# Downloading Data Demo
## Data download using ridigbio and spocc
## 2020-01-29
## ML Gaynor

# Install packages
install.packages(c("ridigbio", "spocc"))

# Load packages
library(ridigbio)
library(spocc)
library(dplyr)

# Using the ridigbio package
## Get records

### Scientific names
records_SN <- idig_search_records(rq=list(
  scientificname = "Galax urceolata"))

### Family
records_family <- idig_search_records(rq=list(
  family = "Asteraceae"), limit = 1000)

### How would you explore the data? (Using dplyr)
(state_count <- records_SN %>%
                group_by(stateprovince) %>%
                count())

(state_count <- records_SN %>%
                group_by(stateprovince) %>%
                summarize(count = n()))

View(state_count)

## Count records
### Scientific name
(count_SN <- idig_count_records(rq=list(
  scientificname = "Galax urceolata")))

## Search records 
### Scientific name
(search_SN <- idig_search(rq=list(
  scientificname = "Galax urceolata")))

#### How is this different from records_SN?
nrow(records_SN)
nrow(search_SN)

ncol(records_SN)
ncol(search_SN)

colnames(records_SN)
colnames(search_SN)

## Get records within an extent

rq_input <- list("scientificname" = list("type" = "exists"),
                 "family" = "asteraceae", 
                  geopoint = list(
                   type = "geo_bounding_box",
                   top_left = list(lon = -87.86, lat = 30.56),
                   bottom_right = list(lon = -79.21, lat = 24.78)
                 ))

records_family_florida <- idig_search_records(rq_input, 
                                              limit = 1000)

head(records_family_florida)

# Using the spocc package
## Get records
spocc_SN <- occ(query = "Galax urceolata", 
                from = c('idigbio', 'gbif', 'bison'),
                has_coords = TRUE)
spocc_SN

spocc_SN_gbif <- spocc_SN$gbif$data$Galax_urceolata
colnames(spocc_SN_gbif)

## Occurrence to dataframe 
spocc_SN_df <- occ2df(spocc_SN)
spocc_SN_df

