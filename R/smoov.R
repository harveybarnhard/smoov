#' Simple mapping tool
#'
#' @param geo 
#'     Character string; Provide level of map geography e.g. county.
#'     See details below for more information 
#' @param data
#'     Dataframe; ID columns matching the level of geography. See details
#'     for more information on column naming
#' @param value
#'     character; Name of the column in \code{data} with which a
#'     choropleth is created.
#' @param bins
#'     integer; 5 by default.
#' @param ...
#'     Optional parameters depending on choice of \code{shape}.

smoov = function(geo, data, value , bins=5, ...){
  arguments = list(...)
  return(arguments)
  # Create smoov environment if it does not already exist
  if(!exists(".smoov_env")){
    .smoov_env = new.env()
  }
  
  # Load shapefile
  smoov_load(geo, data) #TODO create smoov_load()
  
  # Plot shapefile
  smoov_plot() #TODO create smoov_plot()
  
  # Handle geography input
  if(geo%in%c("state", "states")){
    shape="states"
  }else if(shape%in%c("county","counties")){
    shape="counties"
  }else if(geo%in%c("tract", "tracts",
                    "tract2000", "tract2010",
                    "tracts2000", "tracts2010")){
    if(!"tractyear"%in%names(arguments)){
      warning(paste0("geo=tract but no value of tractyear given.",
                     "Defaulting to 2010 tract definitions."))
      tractyear = 2010
    }else{
      tractyear = arguments[["tractyear"]]
    }
    shape=paste0("tracts", )
  }else{
    stop(paste0(geo, " is not a mappable geography with smoov"))
  }
  
  # l

}
