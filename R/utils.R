#' Helper function for smoov(). This function accepts input for states,
#' counties, and tracts, and outputs a vector of 11 digit fips codes
standardize_geo = function(state=NULL, county=NULL, tract=NULL){
  state = as.character(state)
  county = as.character(county)
  tract = as.character(tract)
  
  if(state!=NULL){
    if(is.numeric(state)){
      state = sprintf("%02d", state)
    }
    else if(all(nchar(state))%in%c(1,2))){
      state = sprintf("%02d", as.numeric(state))
    }else{
      # TODO: lookup table for state
    }
  }
  if(county!=NULL){
    if(all(nchar(state.name))==3)){
      
    }else if(all(nchar(state.name))==5){
      
    }else{
      # TODO: lookup table for state
    }
  }
  if(tract!=NULL){
    if(any(nchar(tract)!=6)){
      stop("Only 6-digit tract codes accepted as input.")
    }else if(is.numeric(tract)){
      tract = as.character(tract)
    }
  }
}