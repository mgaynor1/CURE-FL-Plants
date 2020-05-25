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
| | Description |
| ---------- | -------------------- |
| 01_OccurrenceDataDownload.R | Download specimen records for a list of synonymns |
| 02_OccurrenceDataCleaningStep1.R| Identify specimen needing to be georeferenced or requested directly from the collection |
| 03_OccurrenceDataCleaningStep2.R| Combined raw, georeferenced, and requested specimen records. Clean occurrence data. |
| 04_ClimateLayers.R| Trim climatic layer for training and for projection |
| 05_ClimaticNiche.R| Investigate climatic niche |
| 06_EcologicalNicheModeling.R| Examine ENM generated in Maxent |
| 07_ENMProcessing.R| Niche breath, niche overlap, and geographic overlap |

### Locality data collection 
**01_OccurrenceDataDownload.R and 02_OccurrenceDataCleaningStep1.R**
Occurrence records were obtained from [iDigBio](https://www.idigbio.org), [GBIF](https://www.gbif.org), and [BISON](https://bison.usgs.gov). We downloaded data using [ridigbio](https://github.com/iDigBio/ridigbio) and [spocc](https://github.com/ropensci/spocc), then format the data with packages included in tidyverse (Wickham et al., 2019) using custom scripts (mgaynor1/CURE-FL-Plants) in R version 3.6.2 (R Development Core Team, 2019). Utilizing custom functions, we determined which specimens have information withheld or those that needed to be georeferenced. We contacted select herbariums to obtain withheld data and georeferenced as many identified specimens as possible. Georeferencing was conducted on [GEOLocate Web Application](http://www.geo-locate.org/web/WebGeoref.aspx).  
  
### Cleaning Occurrence Data   
**03_OccurrenceDataCleaningStep2.R**
We inspect the occurrence records for each species to identify records that should be removed. Next, we filtered our records to only include our focal species and recognized synonyms. Any record for which coordinates were absent was remove. Locality coordinates were checked for appropriate precision (<1 km) and institution points were removed using the cc_inst function from the R package CoordinateCleaner ([Zizka et al., 2019](https://doi.org/10.1111/2041-210X.13152)). Finally, we removed duplicates and retained only one point per pixel.   

### Climatic layers   
**04_ClimateLayers.R**

### Climatic niche   
**05_ClimaticNiche.R**

### Ecological niche modeling 
**06_EcologicalNicheModeling.R**

### ENM Processing 
**07_ENMProcessing.R**
   