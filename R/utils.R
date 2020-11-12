#' Helper function for smoov(). This function accepts input for states,
#' counties, and tracts, and outputs an vector equal to the length of each
#' input vector, or the length of the smallest geography vector if only
#' one of each of the larger geographies is provided.
#' 
#' @export
create_fips = function(state=NULL, county=NULL, tract=NULL){
  if(!is.null(state)){
    if(is.numeric(state)){
      fips = sprintf("%02d", state)
    }
    else if(all(nchar(state))%in%c(1,2)){
      fips = sprintf("%02d", as.numeric(state))
    }else{
      # TODO: lookup table for state
    }
  }
  if(!is.null(county)){
    # Input error handling
    if(is.null(list(state))){
      stop("`states` must also be provided along with `counties`, ",
           "but no `states` provided")
    }
    if(length(state)>1 & length(state)!=length(county)){
      stop("More than one state provided but length of `counties` vector ",
           "(", length(county), ") does not equal length of `states` vector ",
           "(", length(state), "). This inequality is only allowed when one ",
           "state is provided in `states` vector")
    }
    
    # Make sure county codes are appropriate length
    if(is.numeric(county)){
      county = sprintf("%03d", county)
    }
    else if(all(nchar(county)%in%c(1,2,3))){
      county = sprintf("%03d", as.numeric(county))
    }else{
      # TODO: lookup table for county names?
    }
    
    # Paste state and county together
    fips = paste0(fips, county)
  }
  if(!is.null(tract)){
    # Input error handling
    if(any(is.null(list(state, county)))){
      stop("`states` and `counties` must be provided along with `tracts`")
    }
    if((length(state)>1 | length(county)>1) & 
       !(length(state)==length(county) & length(county)==length(tract))){
      stop("More than one state or county provided but length of `counties` ",
           "vector (", length(county), "), length of `states` vector ",
           "(", length(state), "), and length of `tracts` vector ",
           "(", length(tract), ") are not all equal. This inequality ",
           "is only allowed when one state and one county are provided.")
    }
    
    # Make sure tract codes are appropriate length
    if(all(nchar(tract)<=6)){
      tract = stringr::str_pad(tract, 6, side="right", pad= "0")
    }else{
      stop("Tract codes should not exceed six digits!")
    }
    
    # Paste state, tract, and county together
    fips = paste0(fips, tract)
  }
  if(exists("fips")){
    return(fips)
  }
}