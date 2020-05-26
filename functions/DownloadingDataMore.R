# Functions for Downloading Data 
## 2020-05
## ML Gaynor

# Load packages
require(dplyr) # v.0.8.5 
require(tidyr) # v.1.0.2 
require(plyr) # v.1.8.6
require(spocc) # v.1.0.8
require(ridigbio) # v.0.3.5
require(tibble) # v.3.0.0

# matchColClasses
## Source: https://stackoverflow.com/questions/49215193/r-error-cant-join-on-because-of-incompatible-types
matchColClasses <- function(df1, df2) {
  sharedColNames <- names(df1)[names(df1) %in% names(df2)]
  sharedColTypes <- sapply(df1[,sharedColNames], class)
  for (n in sharedColNames) {
    class(df2[, n]) <- sharedColTypes[n]
  }
  return(df2)
}

######################################

# Make name list
list_of_wants <- read.csv("data/dwc/Whatfeilds.csv")
idigbio_fields <- as.character(list_of_wants$idigbio[1:16])
idigbio_fields_all <- as.character(list_of_wants$idigbio)
gbif_fields <- as.character(list_of_wants$gbif_occurence_raw)
bison_fields <- c(as.character(list_of_wants$bison[1:14]),as.character(list_of_wants$bison[17]))
bison_fields_all <- as.character(list_of_wants$bisonB)
new_names <- as.character(list_of_wants$rename)

# Correct class
correct_class <- function(reduceddataframe){
  reduceddataframe$name <- as.character(reduceddataframe$name)
  reduceddataframe$basis <- as.character(reduceddataframe$basis)
  reduceddataframe$date <- as.character(reduceddataframe$date)
  reduceddataframe$institutionID <- as.character(reduceddataframe$institutionID)
  reduceddataframe$collectionCode <- as.character(reduceddataframe$collectionCode)
  reduceddataframe$collectionID <- as.character(reduceddataframe$collectionID)
  reduceddataframe$country <- as.character(reduceddataframe$country)
  reduceddataframe$county <- as.character(reduceddataframe$county)
  reduceddataframe$state <- as.character(reduceddataframe$state)
  reduceddataframe$locality <- as.character(reduceddataframe$locality)
  reduceddataframe$Latitude <- as.numeric(reduceddataframe$Latitude)
  reduceddataframe$Longitude<- as.numeric(reduceddataframe$Longitude)
  reduceddataframe$ID <- as.character(reduceddataframe$ID)
  reduceddataframe$coordinateUncertaintyInMeters <- as.character(reduceddataframe$coordinateUncertaintyInMeters)
  reduceddataframe$informationWithheld <- as.character(reduceddataframe$informationWithheld)
  reduceddataframe$habitat <- as.character(reduceddataframe$habitat)
  reduceddataframe$prov <- as.character(reduceddataframe$prov)
  return(reduceddataframe)
}

# getidigbio
getidigbio <- function(synonyms_list){
        spocc_idigbio <- ridigbio::idig_search_records(rq = list(scientificname=synonyms_list),
                                                       fields = idigbio_fields)
        
        spocc_idigbio_reduced <- spocc_idigbio  %>%
                                  mutate(prov = "idigbio") %>%
                                  select(tidyselect::all_of(idigbio_fields_all))
        colnames(spocc_idigbio_reduced) <- new_names
        spocc_idigbio_reduced <- correct_class(spocc_idigbio_reduced)
        return(spocc_idigbio_reduced)
}


# getgbif
getgbif <- function(spocc_query){
        spocc_asgbif <- spocc_query$gbif
        spocc_gbif <- occ2df(spocc_asgbif)
        spocc_gbif <- check_columns(spocc_gbif, gbif_fields) 
        spocc_gbif_reduced <- select(spocc_gbif, tidyselect::all_of(gbif_fields))
        spocc_gbif_reduced <- as.data.frame(spocc_gbif_reduced)
        colnames(spocc_gbif_reduced) <- new_names
        spocc_gbif_reduced <- correct_class(spocc_gbif_reduced)
        return(spocc_gbif_reduced)
}

# getbison
getbison <- function(spocc_query){
        spocc_asbison <- (spocc_query$bison)
        spocc_bison <- occ2df(spocc_asbison)
        spocc_bison <- check_columns(spocc_bison, bison_fields_all) 
        spocc_bison_reduced <- select(spocc_bison, all_of(bison_fields_all)) #
        colnames(spocc_bison_reduced) <- new_names
        spocc_bison_reduced <- correct_class(spocc_bison_reduced)
        return(spocc_bison_reduced)
}

# spocc_combine
spocc_combine <- function(synonyms_list, newfilename){
        spocc_query <- occ(query = synonyms_list, 
                       from = c('gbif', 'bison', 'idigbio'), 
                       has_coords = FALSE)
        spocc_query_df <- occ2df(spocc_query)
        spocc_query_df <- spocc_query_df %>%
                         select(spocc.latitude  = latitude, 
                                  spocc.longitude = longitude, 
                                  ID = key,
                                  spocc.prov = prov,
                                  spocc.date = date,
                                  spocc.name = name)
        bison_level <- nlevels(spocc_query$bison)
        if(bison_level == 0){
          # Query parts
          query_idigbio <- getidigbio(synonyms_list)
          query_gbif <- getgbif(spocc_query)
          # Join 
          query_combinedA <- full_join(query_idigbio, query_gbif)
          query_combinedB <- left_join(query_combinedA,spocc_query_df, by = "ID" )
          # Write as csv
          write.csv(query_combinedB, newfilename, row.names = FALSE)
      
        } else {
          # Query parts
          query_idigbio <- getidigbio(synonyms_list)
          query_gbif <- getgbif(spocc_query)
          query_bison <- getbison(spocc_query)
          # Join 
          query_combinedA <- full_join(query_idigbio, query_gbif)
        	# Join 
        	query_combinedB <- full_join(query_bison, query_combinedA)
        	query_combinedC <- left_join(query_combinedB, spocc_query_df, by = "ID" )
        	
        	# Write as csv
        	write.csv(query_combinedC, newfilename, row.names = FALSE)
	}
}


# Check columns
 check_columns <- function(spocc_name, fields){
   diff1 <- setdiff(fields,colnames(spocc_name))
   newframe <- data.frame(matrix(, nrow = 1 , ncol= as.numeric(length(diff1))))
   colnames(newframe) <- diff1
   spocc_name_new <- cbind(spocc_name, newframe)
   return(spocc_name_new)
 }
