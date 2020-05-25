# Occurrence_Data_Cleaning.R
## Occurrence Data cleaning demo based on practice data
## 2020-02-12
## Updated: 2020-02-18
## ML Gaynor

# Install Packages
#install.packages(c("tidyr", "rjson", "RCurl", 
#                 "raster", "sp", "ggplot2"))

# Load packages
library(dplyr)
library(tidyr)
library(rjson)
library(RCurl)
library(raster)
library(sp)
library(ggplot2)

# Load data file
raw.data <- read.csv("data/SampleFL-data.csv")
head(raw.data)

# Explore the datafile 
(species_count <- raw.data %>%
                  group_by(species) %>%
                  tally())

# Taxonomic cleaning 
## Why? Lots of bad names due to misspelling, synonymns, 
## and more 

## iPlant TRNS tool 
### Transforming the species list
#### List of names
(names <- species_count$species)
#### gsub - replaces the _ with a space
(names <- gsub('_', ' ',names))
#### Turn the list into a string by adding commas
(names <- paste(names, collapse=", "))
#### RCurl package to make the string URL encoded
names <- curlEscape(names)
#### Query the API
tnrs.api<-'http://tnrs.iplantc.org/tnrsm-svc'
url<-paste(tnrs.api,'/matchNames?retrieve=best&names=',
           names,
           sep='')
tnrs.json<-getURL(url) 

#### Process results
tnrs.results <- fromJSON(tnrs.json)

corrected_names <- sapply(tnrs.results[[1]], 
                          function(x) 
                            c(x$nameSubmitted, 
                              x$acceptedName))
#### Make into the needed format
corrected_names <- gsub(" ", "_", corrected_names)

corrected_names <- as.data.frame(t(corrected_names), 
                                 stringsAsFactors=FALSE)
names(corrected_names) <- c("species", "new")
corrected_names$species <- gsub("_P", "P", 
                                corrected_names$species)
corrected_names$species <- gsub("_A", "A",
                                corrected_names$species)
corrected_names
#### Correct the names in the OG data frame
merged_datasets <- merge(raw.data, corrected_names, 
                         by = "species")
head(merged_datasets)

# Data cleaning 
merged_datasets$year <- gsub("\\N", NA, 
                             merged_datasets$year)
## Is there any other issues?
(year_count <- merged_datasets %>%
               group_by(year) %>%
               tally())

# Location cleaning
## Round to 2 decimal places
merged_datasets$lat <- round(merged_datasets$lat, 
                             digits = 2)
merged_datasets$long <- round(merged_datasets$long, 
                             digits = 2)

## Remove impossible points 
merged_datasets <- merged_datasets %>%
                   filter(lat != 0, long != 0)

## Remove points that are botanical gardens
bg.points <- read.csv("data/BotanicalGardensFloridaCoordinates.csv", 
                      header = TRUE)
### Filter the bg.points
merged_datasets <- merged_datasets %>%
                   filter(!lat %in% bg.points$Lat &
                          !long %in% bg.points$Long)
nrow(merged_datasets)
##### Next class starts here ####
### Filter for unique 
merged_datsets.unique <- merged_datasets %>%
                         distinct

nrow(merged_datsets.unique)

## Trimming to the desured area
### Use the package raster to create a raster layer of the USA. 
usa <- raster::getData('GADM', country = 'USA', level = 2)

### Subset Florida from the USA map
florida <- subset(usa, NAME_1 == "Florida")
plot(florida) #raster

### Next, convert the merged dataset unique into a spatial file
xy_data <- data.frame(x = merged_datsets.unique$long, 
                      y = merged_datsets.unique$lat)
coordinates(xy_data) <- ~ x + y
proj4string(xy_data) <- crs("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

### extract the values of points for the Florida Polygon
over <- over(xy_data, florida)
total <- cbind(merged_datsets.unique, over)
florida_points <- total %>%
                  filter(NAME_1 == "Florida") %>%
                  dplyr::select(new, lat, long) %>%
                  rename(species = new) 
                  # rename(replace = c("species" = "new")) # If dplyr is weird
head(florida_points)

## Plotting 
### Get the map
states <- map_data("state")
florida <- subset(states, region == "florida")
plot(florida) # polygon 

### ggplot
map_of_samples <- ggplot() +
                  geom_polygon(florida, mapping = aes(x = long, y = lat),
                               color = "black", fill = "gray", size = .2) +
                  geom_point(florida_points, mapping = aes(x = long, y = lat,
                                                           col = species))

map_of_samples

# Save as csv
write.csv(florida_points, 
          "data/cleaned_occurrence/MaxEntPointsInput_cleaned.csv", 
          row.names = FALSE)

