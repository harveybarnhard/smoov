#' Simple mapping tool
#'
#' @param shape 
#'     Character string; Provide level of map geography e.g. county.
#'     See details below for more information 
#' @param data
#'
#' @param ...
#'     Optional parameters depending on choice of \code{shape}.
#'    
#'
smoov = function(geo, ...){
  arguments = list(...)
  return(arguments)
  # Create smoov environment if it does not already exist and pull basepath
  if(!exists(".smoov_env")){
    .smoov_env = new.env()
    assign("smoovpath", envir=.smoov_env)
  }
  
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
  
  # Load shapefile if it is not already loaded
  if(!exists(, envir=.smoov_env))
  assign(
    "shp",
    rgdal::readOGR(
      dsn=file.path(smoovpath, shape),
      layer=shape
    ),
    envir = .smoov_env
  )
  shp = rgdal::readOGR(
    dsn=file.path(smoovpath, shape),
    layer=shape
  )
}
