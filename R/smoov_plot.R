#' Helper function for `smoov()`

smoov_plot = function(geo, data, value, year, detailed, class){
  if(is.logical(detailed)){
    ifelse(detailed, detailed <- "detailed", detailed <- "coarse")
  }
  # Only consider non-NA values
  value = value[!is.na(value)]
  
  # Read in the map from .rds format
  smoovpath = local(smoovpath, envir=.smoov_env)
  shppath   = file.path(smoovpath,
                        paste0(paste(geo, year, detailed, class, sep="_"),
                               ".rds"))
  if(!file.exists(shppath)){
    stop(paste0("no file exists at ", shppath, 
                " Try other values for `year` `detailed` and `class`."))
  }
  shp = readRDS(shppath)
  
  # Subsetting
  #TODO create subsetting here
  shp = shp[substr(shp$fips, 1, 2)=="01",]
  data = data.frame(shp)
  data = data[, c(id, value)]
  
  # Merge data onto shapefile if data nad values provided
  if(!is.null(data) & length(value)>0){
    if(!value%in%colnames(data)){
      stop(paste0(value, " is not the name of a column in provided data."))
    }
    temp = merge(shp, data, by.x="fips", by.y=id, all.x=TRUE)
  }
  
  if(class=="sf"){
    if(length(value)==0){
      return(ggplot2::ggplot(temp) + 
               ggplot2::geom_sf())
    }else{
      return(ggplot2::ggplot(temp) +
               ggplot::geom_sf(aes(fill=value)))
    }
  }else if(class=="sp"){
    #TODO perform case for sp
  }
}

# do.call(`::`, list("smoov", "geo_table"))