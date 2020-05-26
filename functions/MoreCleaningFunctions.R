# MoreCleaningFunctions.R
## Additional functions to aid cleaning
## 2020-03-16
## ML Gaynor

# Load packages
library(dplyr)
library(ridigbio)

## needed_records function
needed_records <- function(occurrence_records){
  
  information_needed <- occurrence_records %>%
    filter(informationWithheld != "NA") %>%
    filter(prov == "idigbio")
  uuid_list <- information_needed$ID
  idigbio_info <- bind_rows(lapply(uuid_list, function(x) idig_search_records(rq = list(uuid = x), fields=c("uuid", "data.dwc:catalogNumber", "scientificname", "collectionname", "data.dwc:datasetName",  "data.dwc:institutionCode"))))
  return(idigbio_info)
}

## needed_to_georeference function
need_to_georeference <- function(occurrence_records){
  occurrence_records$Latitude <- coalesce(occurrence_records$Latitude, 
                                          occurrence_records$spocc.latitude)
  occurrence_records$Longitude <- coalesce(occurrence_records$Longitude, 
                                           occurrence_records$spocc.longitude)
  for_georeferencing <- occurrence_records %>%
    filter(locality != 'NA') %>%
    filter(is.na(Latitude)) %>%
    filter(is.na(Longitude)) %>%
    dplyr::rename(uuid = ID)
  uuid_list <- for_georeferencing$uuid
  idigbio_info <- bind_rows(lapply(uuid_list, function(x) idig_search_records(rq = list(uuid = x), fields=c("uuid", "data.dwc:catalogNumber", "scientificname", "collectionname", "data.dwc:datasetName",  "data.dwc:institutionCode"))))
  for_georeferencing_all <- left_join(for_georeferencing, idigbio_info, by = "uuid")
  return(for_georeferencing_all)
}

# readraw function
readraw <- function(file){
  df <- read.csv(file, 
                 colClasses = c(rep("character",10), "numeric", "numeric", rep("character",5), rep("numeric", 2),  rep("character", 3)))
  return(df)
}

# readgeoref function
readgeoref <- function(file){
  dfg <- read.csv(file, 
                  colClasses = c("character", "numeric", "numeric", rep("character", 6)))
  return(dfg)
}

# readflas function
readflas <- function(file){
  dff <- read.csv(file, 
                  colClasses = c(
                                 rep("character",4), "numeric", 
                                 rep("character", 26), rep("numeric", 3),
                                 rep("character", 5), rep("numeric", 3), 
                                 rep("character", 3), rep("numeric", 3),
                                 rep("character", 2), "numeric", rep("character", 3)))   
  return(dff)
}

# readflasfilered function
readflasfiltered <- function(file){
                      dff <- read.csv(file, colClasses = c(rep("character",10), "numeric", "numeric", rep("character",4)))
                      
                      dff_filtered <- dff %>% 
                                      filter(!is.na(Longitude)) %>%
                                      filter(!is.na(Latitude))
                      return(dff_filtered)
}

# flas_needed function
queryforflas <- function(FLAS_df){
          uuid_list <- FLAS_df$UUID
          idigbio_info <- bind_rows(lapply(uuid_list, function(x) idig_search_records(rq = list(occurrenceid = x), fields=c("uuid", "data.dwc:catalogNumber", "scientificname", "collectionname", "data.dwc:datasetName",  "data.dwc:institutionCode", "occurrenceid"))))
          if (nrow(idigbio_info) >= 1){
              idigbio_info <- idigbio_info %>%
                              dplyr::rename(UUID = occurrenceid)
              FLAS_df <- left_join(FLAS_df, idigbio_info, by = "UUID")
          } else{
            FLAS_df <- FLAS_df %>%
                       mutate(uuid = NA)
            
          } 
          return(FLAS_df)
}

flas_needed <- function(FLAS_df){
   FLAS_df <- queryforflas(FLAS_df)
   FLAS_df_standardized <- FLAS_df %>%
                            dplyr::rename(data = DateColl, 
                                   institutionID = InstCode, 
                                   country = Country, 
                                   county = County, 
                                   state = State, 
                                   Latitude = Lat, 
                                   Longitude = Long, 
                                   ID = uuid, 
                                   habitat = Habitat) %>%
                            mutate(basis = "PRESERVED_SPECIMEN", 
                                   collectionID = NA, 
                                   collectionCode = NA,
                                   locality = paste(LocalityName, LabelInfo, paste("Cult", Cult., sep = " = "), Locality, sep = ", "),  
                                   coordinateUncertaintyInMeters = NA, 
                                   prov = "idigbio")
  FlAS_neeedinfo <- FLAS_df_standardized %>%
                    dplyr::select(finalname, basis, data, institutionID, collectionCode, 
                           collectionID, country, county, state, locality, 
                           Latitude, Longitude, ID, coordinateUncertaintyInMeters, 
                           habitat, prov) %>%
                    dplyr::rename(name = finalname)
  
  return(FlAS_neeedinfo)
}

# matchColClasses function
## Source: https://stackoverflow.com/questions/49215193/r-error-cant-join-on-because-of-incompatible-types
matchColClasses <- function(df1, df2) {
  
  sharedColNames <- names(df1)[names(df1) %in% names(df2)]
  sharedColTypes <- sapply(df1[,sharedColNames], class)
  
  for (n in sharedColNames) {
    class(df2[, n]) <- sharedColTypes[n]
  }
  
  return(df2)
}
