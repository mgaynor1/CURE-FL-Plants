# Functions for ENMProcessing

# Load packages
library(ENMeval)
library(raster)
library(hypervolume)

# enmeval_models function
enmeval_models <- function(occ){
modeval <- ENMevaluate(occ = Pinus_palustris[, c("long", "lat")], 
                       env = envt.subset,
                       bg.coords = bg,
                       algorithm = 'maxnet',
                       RMvalues = c(1, 2.5, 5),
                       fc = c("L", "H", "LQH"), #L=linear, Q=quadratic, P=product, T=threshold, and H=hinge 
                       method = "block",
                       aggregation.factor = c(2,2),
                       clamp = TRUE, 
                       rasterPreds = TRUE,
                       parallel = TRUE,
                       numCores = 4,
                       bin.output = TRUE,
                       progbar = TRUE)
bestmod = which(modeval@results$AICc==min(modeval@results$AICc))
bestmod_prediction <- modeval@predictions[bestmod,]
bestmod_prediction <- raster(bestmod_prediction)
return(bestmod_prediction)
}


# make_binary_map function
make_binary_map <- function(model, occ){
      SuitabilityScores <- extract(model, occ[,3:2])
      SuitabilityScores <- SuitabilityScores[complete.cases(SuitabilityScores)]
      # Reclassify the raster; set threshold to 
      ## minimum suitability score at a known occurrence
      threshold <- min(SuitabilityScores)
      M <- c(0, threshold, 0,  threshold, 1, 1); 
      rclmat <- matrix(M, ncol=3, byrow=TRUE);
      Dist <- reclassify(model, rcl = rclmat);
}

# get_hypervolume
get_hypervolume <- function(binary_map, envt) {
  dist.points <-  rasterToPoints(binary_map)
  # Need predicted occurrence points (calculated from thresholded model)
  hv.dat <- extract(envt, dist.points[,1:2]);
  hv.dat <- hv.dat[complete.cases(hv.dat),];
  hv.dat <- scale(hv.dat, center=TRUE, scale=TRUE)
  hv <- hypervolume(data = hv.dat, method = "box")
}

