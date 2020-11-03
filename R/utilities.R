smoov_load = function(geo, data){
  # Allow for unconventional input for geo to work
  shape = smoov::geo_table[geo_table$alias==geo,]$name
  
  # Read in the map from .rds format
  data()
  shppath = file.path(
    local(smoovpath, envir=.smoov_env), "smoov", paste0(shape, ".rds")
  )
  if(!file.exists(shppath)){
    stop(paste0(shape, " is not a mappable geography with smoov."))
  }else{
    assign(shape, readRDS(shppath), envir=.smoov_env)
  }
  
  # Merge data onto shapefile
  
}

#TODO make smoov_plot its own thing
smoov_plot = function(){
  
}
