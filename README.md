# CURE-FL-Plants
Spring 2020.   
ML Gaynor.   

## **Purpose**:   
For sharing course material created during Spring 2020 at the University of Florida for 'CURE: Florida Plants and Climate Change'. This class was a 3 credit undergraduate course I taught with Pam and Doug Soltis.

**CURE**: Course-based Undergraduate Research Experience.  

## Data accessibility. 
These analysis were focused on endangered/threatened species, therefore we did not include the datafiles in this repository. 
  

## Demos
| Demos | Description |
| ---------- | -------------------- |
| 01_Rbasics | Basic introduction to R based on [Chapters 1 - 5](https://datacarpentry.org/R-ecology-lesson/index.html) |
| 02_DownloadingData |Downloaded data using the iDigBio API |
| 03_Georeferencing |Georeference specimen without LatLong |
| 04_Occurrence_data_cleaning | Clean specimen records |
| 05_Takehome_Demos | Used maxent to generate current ecological niche models |
| 06_ENMDemo | ENM in R (without rJava) |

## CURE Project
**See 00-CURE_FloridaPlants.pdf for these scripts!**

| | Description |
| ---------- | -------------------- |
| 01_OccurrenceDataDownload.R | Download specimen records for a list of synonymns |
| 02_OccurrenceDataCleaningStep1.R| Identify specimen needing to be georeferenced or requested directly from the collection |
| 03_OccurrenceDataCleaningStep2.R| Combined raw, georeferenced, and requested specimen records. Clean occurrence data. |
| 04_ClimateLayers.R| Trim climatic layer for training and for projection |
| 05_ClimaticNiche.R| Investigate climatic niche |
| 06_EcologicalNicheModeling.R| Examine ENM generated in Maxent |
| 07_ENMProcessing.R| Niche breath, niche overlap, and geographic overlap |

### <span style="color: blue">Locality data collection </span>. 
**01_OccurrenceDataDownload.R and 02_OccurrenceDataCleaningStep1.R**
Occurrence records were obtained from [iDigBio](https://www.idigbio.org), [GBIF](https://www.gbif.org), and [BISON](https://bison.usgs.gov). We downloaded data using [ridigbio](https://github.com/iDigBio/ridigbio) and [spocc](https://github.com/ropensci/spocc), then format the data with packages included in tidyverse (Wickham et al., 2019) using custom scripts (mgaynor1/CURE-FL-Plants) in R version 3.6.2 (R Development Core Team, 2019). Utilizing custom functions, we determined which specimens have information withheld or those that needed to be georeferenced. We contacted select herbariums to obtain withheld data and georeferenced as many identified specimens as possible. Georeferencing was conducted on [GEOLocate Web Application](http://www.geo-locate.org/web/WebGeoref.aspx).  
  
### <span style="color: blue"> Cleaning Occurrence Data </span>    
**03_OccurrenceDataCleaningStep2.R**
We inspect the occurrence records for each species to identify records that should be removed. Next, we filtered our records to only include our focal species and recognized synonyms. Any record for which coordinates were absent was remove. Locality coordinates were checked for appropriate precision (<1 km) and institution points were removed using the cc_inst function from the R package CoordinateCleaner ([Zizka et al., 2019](https://doi.org/10.1111/2041-210X.13152)). Finally, we removed duplicates and retained only one point per pixel.    

### <span style="color: blue"> Climatic layers </span>   
**04_ClimateLayers.R**
We obtained 19 environmental layers of current (1950 - present) BioClim dataset from the [WorldClim database](https://www.worldclim.org/). We cropped all layers to the extent of Florida with the [raster R package](https://cran.r-project.org/web/packages/raster/raster.pdf). Based on the Florida extent layers, we removed highly correlated layers (>|0.80|) with a pairwise correlation analysis. We retained annual mean temperature, mean diurnal range, isothermality, minimum temperature of the coldest month, mean temperature of the driest quarter, annual precipitation, precipitation of the driest month, and precipitation of the warmest quarter. The retained Florida extent layers will be referred to as the ‘current projection’ layers. For each species, we then trimmed the retained layers to the extent of a convex hull and buffer of 1° with the [R package rgeos](https://cran.rstudio.com/web/packages/rgeos/rgeos.pdf) (Bivand et al., 2019), this represents the  ‘training layer’ for each species.     

We obtained matching future projected BioClim layers from the WorldClim database. Specifically, we used CCSM4, a commonly implemented climate models from the Coupled Model Intercomparison Project Phase 5 for 2050 (average for 2041-2060) and 2070 (average 2061-2080) at one greenhouse gas representative concentration pathway (rcp) trajectories of 2.6 ([Riahi et al. 2011](https://link.springer.com/article/10.1007/s10584-011-0149-y)). Each future layer also had the spatial resolution of 30 arcsec and was trimmed to the Florida extent.   


### <span style="color: blue"> Climatic niche </span>   
**05_ClimaticNiche.R**
To investigate the realized niche of the species, we point sampled the current bioclimatic niche at each occurrence. We then conducted a principal component analysis (PCA). For each climatic variable, we analyzed niches among all included species using an analysis of variance (ANOVA) followed by post hoc tests using the Tukey Honest Significant Differences (HSD) method with the [R package agricolae](https://cran.r-project.org/web/packages/agricolae/index.html).   

### <span style="color: blue"> Ecological niche modeling </span>   
**06_EcologicalNicheModeling.R**
Ecological niche models for each species was generated using MaxEnt v. 3.3.3k ([Phillips et al., 2006](https://www.cs.princeton.edu/~schapire/papers/ecolmod.pdf)), based on the eight uncorrelated bioclimatic variables. For all models we ran a maximum of 5000 iterations with 10 bootstrap replicates. We disabled extrapolation of extant species geographic projections and allowed missing data. In addition, 25% of the data was set aside for model testing, and the remainder was used for training. All models were evaluated on their ability to differentiate between suitable and unsuitable areas based on the area under the curve statistic (AUC).
   
We generated three models to evaluate the distribution of each species in current conditions, conditions in 2050, and conditions in 2070. For each model, training layers were used to determine suitability and these models were then projected onto the desired climatic conditions.  


### <span style="color: blue">  ENM Processing </span>    
**07_ENMProcessing.R**
We calculated niche breadth for each species using the raster.breadth function from the [R package ENMTools](https://github.com/danlwarren/ENMTools). Niche breadth measures the smoothness of suitability scores across a projected landscape. The closer niche breadth is to one, the more of the avalible niche space a species occupies.

Next, niche overla or Schoener’s D was calculated using the [R package ENMEval](https://cran.r-project.org/web/packages/ENMeval/index.html). Schoener’s D ranges from zero to one. Zero represents no similarity between projections, while one represents completely identical projections.

Finally, we calculated geographic overlap between the current and future projections. We generated 10,000 random points inside the full extent layers using the function spsample from the [R package sp](https://cran.r-project.org/web/packages/sp/index.html). Suitability score for these random points was extracted from each model. We then set a minimum suitability threshold of 0.25 to signify an area as suitable for each species, while a value under 0.25 was designated unsuitable, for present and future distributions. Geographic overlap (G) was then calculated for each species as the percentage of points found in the present distribution relative to those in the future distribution. 



# Issues and Reuse 
If you have any issues, please feel free to open an issue on github or email me (michellegaynor at ufl.edu). I'd love feedback on this material if you end up using the scripts in classes or research. If you use these scripts in research, please refer to https://github.com/mgaynor1/CURE-FL-Plants in-text. 

Please do not plagurize the text above. Instead, paraphrase and cite this repository. 

