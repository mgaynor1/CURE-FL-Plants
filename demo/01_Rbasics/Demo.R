# Title of My Document 
## More information (why, what)
## OG date:
## Update date: 
## Name 

# Install Packages
install.packages(c("dplyr", "tidyr", "ggplot2"))

# Load packages
library(dplyr)
# dplyr::filter, dplyr::lag
library(ggplot2)
library(tidyr)

# Objects
weight <- 3 # numerical 
weight <- 3L # integer
weight <- 3.5 # double 
weight <- 3+2i # complex
hair <- TRUE # logical
hair <- "yellow" # character
hair = "brown"

# List
## character
sites <- c("a", "b", "c", "d")

## Slice 
### "give me a peice of something"
sites[1:3]

## numbers
areas <- c(5, 12, 10, 11) 
### slicing numbers
areas[3]

# Combinding list 
## combined
combine <- c(sites, areas)
combine

## rbind
### row bind
combine_rbind <-  rbind(sites, areas)
combine_rbind

## cbind
### column bind
(combine_cbind <- cbind(sites, areas))
combine_cbind

## dataframe
### making a dataframe
(xy <- data.frame(sites, areas))
xy

# Explore a dataframe
str(xy)
head(xy)
View(xy) 
xy$areas
class(xy$areas)
length(xy$areas)
nrow(xy)
ncol(xy)

# Data file
df <- read.csv("data/combined.csv", na.strings = "")

# dplyr
## pipes %>%
dfselect <- df %>%
            select(record_id, plot_id, species_id, sex, year) 
            
dffilter <- dfselect %>%
            filter(year > 1980)

dfgroup <- dffilter %>%
           group_by(year) %>%
           summarize(count = n())


            


