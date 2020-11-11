#' Helper function for smoov(). This function accepts input for states,
#' counties, and tracts, and outputs a vector of 11 digit fips codes
standardize_geo = function(state=NULL, county=NULL, tract=NULL){
  state = as.character(state)
  county = as.character(county)
  tract = as.character(tract)
  
  if(state!=NULL){
    if(!all(sapply(state, nchar, USE.NAMES=FALSE)==2)){
      # TODO: lookup table for state
    }
  }
  if(county!=NULL){
    
  }
  if(tract!=NULL){
    
  }
}