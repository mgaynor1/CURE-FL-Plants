# Ecological Niche Modeling
## R based ENM modeling 
## 2020-03-24
## Update: 2020-03-25
## ML Gaynor

# Load packages
library(dplyr)
library(raster)
library(gtools)
library(ENMeval)

# Load occurrence records
Asclepias_curtissii <- read.csv("csv/Asclepias_curtissii.csv")
Asimina_obovata <- read.csv("csv/Asimina_obovata.csv")
Pinus_palustris <- read.csv("csv/Pinus_palustris.csv")

# Load climatic layers
list <- list.files("data/NeededPresentLayers/projection/", 
                   pattern = "*asc", full.names = TRUE, 
                   recursive =  FALSE)
list <- mixedsort(sort(list))
envtStack <- raster::stack(list)

# maxnet model
## Designate Background Points
bg <- randomPoints(envtStack[[1]], n = 10000)
bg <- as.data.frame(bg)
plot(envtStack[[1]], legend = FALSE)
plot(x = bg$x, y = bg$y, col = "red")

## Block method
block <- get.block(Pinus_palustris[, c("long", "lat")], bg)
str(block)
plot(envtStack[[1]], legend = FALSE)
points(Pinus_palustris[, c("long", "lat")], 
       pch = 21,
       bg = block$occ.grp)

## ENMevaluate 
## More info: https://cran.r-project.org/web/packages/ENMeval/vignettes/ENMeval-vignette.html
modeval <- ENMevaluate(occ = Pinus_palustris[, c("long", "lat")], 
                       env = envtStack, 
                       bg.coords = bg, 
                       algorithm = "maxnet", 
                       RMvalues = c(1, 2.5, 5), 
                       fc = c("L", "H", "LQH"), 
                       method = "block", 
                       aggregation.factor = c(2,2), 
                       clamp = TRUE, 
                       rasterPreds = TRUE, 
                       parallel = TRUE, 
                       numCores = 2, 
                       bin.output = TRUE, 
                       progbar = TRUE)

# Look at the results
## Look at the models
modeval@results

## Look at the models
maps <- modeval@predictions
plot(maps)

## Pick the best model
bestmod <- which(modeval@results$AICc == min(modeval@results$AICc))
modeval@results[bestmod, ]

## Plot model statistics
plot(modeval@predictions[[which(modeval@results$delta.AICc == 0)]], 
     main = "Relative occurrence rate")
