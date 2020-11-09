#' Helper function for `smoov()`

smoov_load = function(geo, data, value, year, detailed, class){
  # Allow for unconventional input for geo to work
  if(length(shape)==0){
    stop(paste0(geo, " is not a mappable geography with smoov."))
  }
  
  # Read in the map from .rds format
  smoovpath = local(smoovpath, envir=.smoov_env)
  shppath   = file.path(smoovpath,
                        paste0(paste(geo, year, detailed, class, sep="_"), ".rds"))
  if(!file.exists(shppath)){
    stop(paste0(geo, " is not a mappable geography with smoov. ",
                "Try other values for `year` `detailed` and `class`."))
  }
  shp = readRDS(shppath)
  #TODO create subsetting here
  shp = shp[substr(shp$fips, 1, 2)=="01",]
  # Merge data onto shapefile
  data = data.frame(shp)
  data = data[, c(id, value)]
  if(!value%in%colnames(data)){
    stop(paste0(value, " is not the name of a column in provided data."))
  }
  temp = merge(shp, data, by.x="fips", by.y=id, all.x=TRUE)
  
  if(class=="sf"){
    g = ggplot(temp) + 
      geom_sf(aes())
  }else if(class=="sp"){
    
  }
  return(g)
}

# do.call(`::`, list("smoov", "geo_table"))