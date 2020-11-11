#' Helper function for smoov()
#' This function takes in map data and the dataframe of values, merging them
#' together when appropriate. This function also performs the subsetting 
#' operations if subsetting parameters (states, counties, tracts) are supplied.
#' shp_data_merge() returns a logical vector of length three that
#'     1. Should all of USA be plotted? TRUE/FALSE
#'     2. Should Hawaii be plotted? TRUE/FALSE
#'     3. Should Alaska be plotted? TRUE/FALSE
shp_data_merge = function(shp,
                          data=NULL,
                          id="fips",
                          value=NULL,
                          subfips=NULL){
  
  # Perform subsetting operations on shp =======================================
  if(nchar(subfips[1])>nchar(shp$fips[1])){
    stop("You tried to subset to a finer level of geography than provided by ",
         "`geo`")
  }
  if(!is.null(subfips)){
    shp = shp[.Internal(substr(shp$fips, 1L, as.integer(nchar(subfips[1]))))%in%subfips,]
    unqstates = unique(.Internal(substr(subfips, 1L, 2L)))
  }else{
    unqstates = c() 
  }
  
  # Create logical return values for Hawaii and Alaska
  if(length(unqstates)>0){
    alaska = "02"%in%unqstates; hawaii = "15"%in%unqstates
  }else{
    alaska = TRUE; hawaii = TRUE
  }
  
  # Should all of USA be plotted?
  #    TRUE if both Alaska and Hawaii are plotted
  #    TRUE if One of Alaska or Hawaii are plotted along with at least one
  #         mainland state
  #    FALSE otherwise (e.g. one of Alaska or Hawaii, or mainland states)
  usa = ifelse(alaska&hawaii, TRUE,
               ifelse((alaska|hawaii) & 
                      (length(setdiff(unqstates, c("02", "15")))>0 |
                      length(unqstates)==0),
                      TRUE, FALSE))
  
  # If no data is provided, then map of USA is created
  if(is.null(data) & is.null(value)){
    message("No data or value supplied, plotting map of borders.")
    return(list(shp, c(usa, alaska, hawaii)))
  }
  
  
  # TODO create characteristics for each geography when data=NULL, but value!=NA
  
  # Handle case where any of the value columns are not found
  value = intersect(value, colnames(data))
  if(length(value)==0){
    stop(value, " is not a name of a column in the data supplied.")
  }
  
  # TODO make this subsetting faster by using above subsets
  
  # Perform subsetting operations, allowing for flexible input base on FIPs
  # right now
  # TODO: Create look up table for non-fips (e.g. state-name entries)
  data = data[, c(id, value)]
  data = data[.Internal(substr(shp$fips, 1L, as.integer(nchar(subfips[1])))),]
  
  if(!is.null(states)){
    if(all(nchar(states)==2)){
      data = data[.Internal(substr(data$id, 1L, 2L)) %in% states,]
    }
  }
  if(!is.null(counties)){
    if(all(nchar(counties)==3)){
      counties = paste0(states, counties)
    }
    data = data[.Internal(substr(data$id, 1L, 5L)) %in% counties,]
  }
  if(!is.null(counties)){
    if(all(nchar(tracts)==6)){
      tracts = paste0(states, counties, tracts)
    }
    data = data[.Internal(substr(data$id, 1L, 11L)) %in% tracts,]
  }
  
  # Final step, merge subsetted map and data together
  shp  = merge(shp, data, by.x="fips", by.y=id, all.x=TRUE)
  return(list(shp, c(usa, alaska, hawaii)))
}
