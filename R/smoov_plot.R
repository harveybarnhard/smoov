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
  
  # Merge data onto shapefile if data and values provided
  if(!is.null(data) & length(value)>0){
    if(!value%in%colnames(data)){
      stop(paste0(value, " is not the name of a column in provided data."))
    }
    data = data[, c(id, value)]
    shp = merge(shp, data, by.x="fips", by.y=id, all.x=TRUE)
  }
  
  # Move Hawaii and Alaska
  # https://www.r-spatial.org/r/2018/10/25/ggplot2-sf-3.html
  if(class=="sf"){
    if(length(value)==0 & is.null(data)){
      g = ggplot2::ggplot(shp) +
        ggplot2::geom_sf() +
        ggplot2::coord_sf(crs=sf::st_crs(2163),
                          xlim=c(-2500000, 2500000),
                          ylim=c(-2300000, 730000))
      alaska = ggplot2::ggplot(shp) +
        ggplot2::geom_sf() +
        ggplot2::coord_sf(crs=sf::st_crs(3467),
                          xlim=c(-2400000, 1600000),
                          ylim=c(-200000, 2500000),
                          expand=FALSE, datum=NA) +
        theme_void()
      hawaii = ggplot2::ggplot(shp) +
        ggplot2::geom_sf() +
        ggplot2::coord_sf(crs=sf::st_crs(4135),
                          xlim=c(-161, -154),
                          ylim=c(18, 23),
                          expand=FALSE, datum=NA) +
        theme_void()
    }else{
      return(
        ggplot2::ggplot(shp) + ggplot2::geom_sf(aes(fill=value))
      )
    }
    return(
      g +
        annotation_custom(
          grob = ggplotGrob(alaska),
          xmin = -2750000,
          xmax = -2750000 + (1600000 - (-2400000))/2.5,
          ymin = -2450000,
          ymax = -2450000 + (2500000 - 200000)/2.5
        ) +
        annotation_custom(
          grob = ggplotGrob(hawaii),
          xmin = -1250000,
          xmax = -1250000 + (-154 - (-161))*120000,
          ymin = -2450000,
          ymax = -2450000 + (23 - 18)*120000
        ) +
        theme_void()
    )
  }else if(class=="sp"){
    if(length(value)==0 & is.null(data)){
      return(ggplot2::ggplot(shp, mapping=aes(x=long,
                                              y=lat,
                                              group=group)) +
               ggplot2::geom_polygon())
    }else{
      return(ggplot2::ggplot(shp, mapping=aes(x=long,
                                              y=lat,
                                              group=group,
                                              fill=value)) +
               ggplot2::geom_polygon())
    }
  }
}