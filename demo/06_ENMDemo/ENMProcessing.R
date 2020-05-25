# ENMProcessing
## Basic statistic on generated ENMs
## 2020-03-25
## ML Gaynor

## Install https://www.xquartz.org/ on macos prior

# Load packages
library(raster)
library(ENMTools)
library(ENMeval)
library(hypervolume)
library(gtools)
source("functions/ENMProcessingFunctions.R")

# Load avg files
Asclepias_curtissii_enm <- raster("data/Asclepias_curtissii_model/Asclepias_curtissii_projection_avg.asc")
Asimina_obovata_enm <- raster("data/Asimina_obovata_model/Asimina_obovata_projection_avg.asc")
Pinus_palustris_enm <- raster("data/Pinus_palustris_model/Pinus_palustris_projection_avg.asc")

## Create maxent files
### Load occurrence records
Asclepias_curtissii <- read.csv("csv/Asclepias_curtissii.csv")
Asimina_obovata <- read.csv("csv/Asimina_obovata.csv")
Pinus_palustris <- read.csv("csv/Pinus_palustris.csv")

### Load climatic layers
list <- list.files("data/NeededPresentLayers/projection/", 
                   pattern = "*asc", full.names = TRUE, 
                   recursive =  FALSE)
list <- mixedsort(sort(list))
envt.subset <- raster::stack(list)

### Make the models
Asclepias_curtissii_mn <- enmeval_models(Asclepias_curtissii[, c("long", "lat")])
Asimina_obovata_mn <- enmeval_models(Asimina_obovata[, c("long", "lat")])
Pinus_palustris_mn <- enmeval_models(Pinus_palustris[, c("long", "lat")])

# ENM Breadth 
## The raster.breadth command in ENMTools measures
## the smoothness of suitability scores across a projected landscape.
## The higher the score, the more of the avalible niche space a species occupies. 
## Returns Levins' two metrics of niche breadth. 

(Ac_breadth <- ENMTools::raster.breadth(x = Asclepias_curtissii_enm))
Ac_breadth$B2

(Ac_breadth_mn <- ENMTools::raster.breadth(x = Asclepias_curtissii_mn))
Ac_breadth_mn$B2

# ENM overlap 
## Calculating niche overlap, Schoener's D, 
## with ENMEval - Schoener's D ranges from 0 to 1
## 0 represents no similarity between projections
## 1 represents completely identical projections

## Create a raster stack - maxent
enm_stack <- stack(Asclepias_curtissii_enm, Asimina_obovata_enm, Pinus_palustris_enm)
names(enm_stack) <- c("Asclepias curtissii", "Asimina obovata", "Pinus palustris")

## Calculate niche overlap 
calc.niche.overlap(enm_stack)

## Create a raster stack - maxnet
mn_stack <- stack(Asclepias_curtissii_mn, Asimina_obovata_mn, Pinus_palustris_mn)
names(mn_stack) <- c("Asclepias curtissii", "Asimina obovata", "Pinus palustris")

## Calculate niche overlap 
calc.niche.overlap(mn_stack)

# Hypervolume

## Make binary maps
Asclepias.dist <- make_binary_map(model = Asclepias_curtissii_enm, 
                                  occ = Asclepias_curtissii)
Asimina.dist <- make_binary_map(model = Asimina_obovata_enm, 
                                occ = Asimina_obovata)
Pinus.dist <- make_binary_map(model = Pinus_palustris_enm, 
                              occ = Pinus_palustris)

### Visualizing binary maps
plot(Asclepias_curtissii_enm)
plot(Asclepias.dist)

## Calculate hypervolume
Asclepias.hv <- get_hypervolume(binary_map = Asclepias.dist, 
                                envt = envt.subset)
Asimina.hv <- get_hypervolume(binary_map = Asimina.dist, 
                              envt = envt.subset)
Pinus.hv <- get_hypervolume(binary_map = Pinus.dist, 
                            envt = envt.subset)
summary(Asclepias.hv)

## Get volumes 
get_volume(Asclepias.hv)
get_volume(Asimina.hv)
get_volume(Pinus.hv)

## Make hypervolume set 
hv_set <- hypervolume_set(hv1 = Asclepias.hv, 
                          hv2 = Asimina.hv, 
                          check.memory = FALSE)
plot(hv_set)











