smoov_load = function(geo){
  # Error handle
  # TODO: creating mapping in order to make this one line
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
    shape=paste0("tracts", tractyear)
  }
  
  # Read in the shapefile from .rds format
  shppath = file.path(
    local(smoovpath, envir=.smoov_env), "smoov", paste0(shape, ".rds")
  )
  if(!file.exists(shppath)){
    stop(paste0(shape, " is not a mappable geography with smoov."))
  }
  assign(shape, readRDS(shppath), envir=.smoov_env)
}

#TODO make smoov_plot its own thing
smoov_plot = function(){
  
}
