#' Helper function for smoov_plot()
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
                          states=NULL,
                          counties=NULL,
                          tracts=NULL){
  # Perform subsetting operations on shp
  unqstates = c()
  if(!is.null(states)){
    if(all(nchar(states)==2)){
      unqstates = states
      shp = shp[.Internal(substr(shp$fips, 1L, 2L)) %in% states,]
    }else{
      stop("Improper input for `tracts`. Check string lengths")
    }
  }
  if(!is.null(counties)){
    if(all(nchar(counties)==3)){
      if(is.null(states)){
        stop("Must provide vector of states corresponding to vector ",
             "of counties when providing 3-digit county codes. Try ",
             "using 5 digit county codes instead.")
      }
      if(length(states)==length(counties) | length(states)==1){
        counties = paste0(states, counties)
      }else{
       stop("3-digit county codes provided without corresponding vector ",
            "of 2-digit state codes.") 
      }
    }else if(all(nchar(counties)!=5)){
      stop("Improper input for `counties`. Check string lengths.")
    }
    unqstates = union(unqstates, .Internal(substr(counties, 1L, 2L)))
    shp = shp[.Internal(substr(shp$fips, as.integer(1), as.integer(5))) %in% counties,]
  }
  if(!is.null(counties)){
    if(all(nchar(tracts)==6)){
      if(is.null(states) & is.null(counties)){
        stop("Must provide vector of states and counties corresponding to ",
             "vector of tracts when providing 6-digit tracts codes. Try ",
             "using 11 digit tracts codes instead.")
      }else if(is.null(states) & all(nchar(counties)==5)){
        if(length(counties)==length(tracts) | length(counties)==1){
          tracts = paste0(counties, tracts)
        }else{
          stop("6-digit tract codes and 5-digit county codes provided, ",
               "but vectors are of different lengths.")
        }
      }else if(all(nchar(states)==2) & all(nchar(counties)==3)){
        if(length(states)==length(counties) & length(counties)==length(tracts)){
          tracts = paste0(states, counties, tracts)
        }else{
          stop("6-digit tract codes, 3-digit county codes, and 2-digit state ",
               "codes provided but vector are of different lengths")
        }
      }
    }
    unqstates = union(unqstates, .Internal(substr(tracts, 1L, 2L)))
    shp = shp[.Internal(substr(shp$fips, 1L, 11L)) %in% tracts,]
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
  if(!is.null(states)){
    if(all(nchar(states))==2)){
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
