# Climatic Niche
## Demo for quantifying climatic niche
## 2020-03-18 
### Updated: 2020-03-24
## ML Gaynor

# Install Packages
install.packages("caret")
install.packages(c("tibble", "gtools", 
                   "factoextra", "FactoMineR", "agricolae", 
                   "devtools"))

library(devtools)
install_github("vqv/ggbiplot")

# Load Packages
library(dplyr)
library(tidyr)
library(raster)
library(tibble)
library(gtools)
library(caret)
library(factoextra)
library(FactoMineR)
library(ggbiplot)
library(agricolae)

# Load occurrence records
florida_points <- read.csv("data/MaxEntPointsInput_cleaned.csv")

## What species are in my list?
unique(florida_points$species)

## Seperate species
Asclepias_curtissii <- florida_points %>%
                       filter(species == "Asclepias_curtissii")

Asimina_obovata <- florida_points %>%
                   filter(species == "Asimina_obovata")

Pinus_palustris <- florida_points %>% 
                   filter(species == "Pinus_palustris")


# Climatic layers
## Make list of files
list <- list.files("data/PresentLayers/", 
                   full.names = TRUE, 
                   recursive = FALSE)
### Put List in order using gtools
list <- mixedsort(sort(list))

### Load the rasters 
envtStack <- raster::stack(list)

## Remove correlated layers
c <- data.matrix(read.csv("data/correlationBioclim.csv", 
                          header = TRUE, 
                          row.names = 1, 
                          sep = ","))

### Convert to absolute
c <- abs(c)

### Find the correlation 
envtCor <- caret::findCorrelation(c, cutoff = 0.80,
                                  names = TRUE, exact = TRUE)
sort(envtCor)

### Subset 
envt.subset <- subset(envtStack, c(3, 4, 6, 9, 10, 13, 15, 19)) 
envt.subset

# Point Sample
ptExtract_Asclepias_curtissii <- raster::extract(envt.subset, 
                                                 Asclepias_curtissii[3:2])
ptExtract_Asimina_obovata <- raster::extract(envt.subset, 
                                             Asimina_obovata[3:2])
ptExtract_Pinus_palustris <- raster::extract(envt.subset, 
                                             Pinus_palustris[3:2])

## Convert the ptExtract to a dataframe
convert_ptExtract <- function(value, name){
          value_df <- as.data.frame(value)
          value_df_DONE <- value_df %>%
                           mutate(species = name)
          return(value_df_DONE)
}

ptExtract_Asclepias_curtissii_df <- convert_ptExtract(ptExtract_Asclepias_curtissii, 
                                                      "Asclepias_curtissii")

ptExtract_Asimina_obovata_df <- convert_ptExtract(ptExtract_Asimina_obovata, 
                                                  "Asimina_obovata")

ptExtract_Pinus_palustris_df <- convert_ptExtract(ptExtract_Pinus_palustris, 
                                                  "Pinus_palustris")

### Combined the dataframes and remove NA
pointsamples_combined <- rbind(ptExtract_Asclepias_curtissii_df, 
                          ptExtract_Asimina_obovata_df,
                          ptExtract_Pinus_palustris_df)
pointsamples_combined <- pointsamples_combined %>%
                         drop_na(bio2, bio3, bio5,
                                 bio8, bio9, bio12, 
                                 bio14, bio18)

# PCA
## Create two dataframes
data.bioclim <- pointsamples_combined[, 1:8]
data.species <- pointsamples_combined[, 9]

## Using only the bioclim columns - run a PCA
data.pca <- prcomp(data.bioclim, scale. = TRUE)

## Understanding the PCA
### When you use the command prcomp
### your loading variables show up as rotational variables. 
### Thanks to a really great answer on stack overflow you 
### can even convert the rotational variable to show the 
### relative contribution.

loadings <- data.pca$rotation

### There are two options to convert the 
### loading to show the relative contribution,
## they both give the same answer so either can be used.

loadings_relative_A <- t(t(abs(loadings))/rowSums(t(abs(loadings))))*100
summary(loadings_relative_A)

loadings_relative_B <- sweep(x = abs(loadings), MARGIN = 2,
                             STATS = colSums(abs(loadings)), FUN = "/")*100
summary(loadings_relative_B)

## Plotting the PCA
theme <-  theme(panel.background = element_blank(),
                panel.border = element_rect(fill = NA),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                strip.background = element_blank(),
                axis.ticks = element_line(colour = "black"),
                plot.margin = unit(c(1,1,1,1),"line"), 
                axis.text = element_text(size = 12), 
                legend.text = element_text(size = 12), 
                legend.title = element_text(size = 12), 
                text = element_text(size = 12))

g <- ggbiplot(data.pca, obs.scale = 1, var.scale = 1, 
              groups = data.species, ellipse = TRUE,
              varname.size = 5)
g <- g + theme(legend.position = "right", legend.direction = "vertical")
g <- g + theme
g

# ANOVA
## Bio2
b2_aov <- aov(lm(bio2 ~ species, data = pointsamples_combined))
b2 <- HSD.test(b2_aov, trt = "species", alpha = 0.05)        

### Seperate the groups
bio2_group <- b2$groups
########################################
bio2_group <- rownames_to_column(bio2_group, var = "species")

### Make plotable
part <- pointsamples_combined %>%
        dplyr::select(species, bio2)
bio2pl <- left_join(part, bio2_group, by = "species")

### Plot
bio2_aov_plot <- ggplot(bio2pl, aes(x = species, y = bio2.x)) +
                 geom_boxplot(aes(fill = groups)) +
                 geom_text(data = bio2_group, 
                           mapping = aes(x = species,
                                         y = 150, 
                                         label = groups), 
                           size = 5, inherit.aes = FALSE) +
                theme(axis.text.x = element_text(angle = 90, 
                                                 size = 8, 
                                                 face = 'italic'))
bio2_aov_plot

# Niche overlap 
# More information: https://www.r-bloggers.com/niceoverplot-or-when-the-number-of-dimensions-does-matter/

## Load packages
library(ecospat)
library(grid)
library(gridExtra)
library(gtable)
library(RColorBrewer)
source("functions/niceOverPlot_code.R")

## Make dataframe with AC and AO
ACAO_combined <- rbind(ptExtract_Asclepias_curtissii_df, ptExtract_Asimina_obovata_df)
ACAO_combined <- ACAO_combined %>%
                drop_na(bio2, bio3, bio5,
                        bio8, bio9, bio12, 
                        bio14, bio18)

## dudi.pca
### Create two dataframes
ACAO_data.bioclim <- ACAO_combined[, 4]
ACAO_data.species <- ACAO_combined[, 9]

### Run the dudi.pca
pca.ACAO <- dudi.pca(na.omit(ACAO_data.bioclim, ACAO_data.species, 
                     center = TRUE, scale = TRUE, scannf = FALSE, nf = 2))

## Plot the dudi.pca
### n1 = # of observations in species 1, n2 = # of observations in species 2

niceOverPlot(pca.ACAO, n1 = 21, n2 = 17)














