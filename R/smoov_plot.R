#' Helper function for `smoov()`

smoov_plot = function(geo,
                      data,
                      value=NULL,
                      id,
                      year,
                      detailed,
                      class,
                      subsetfips=NULL,
                      gradient="redblue",
                      gradient_dir=1,
                      gradient_breaks=c(0,0.3,0.5,0.7,1),
                      linesize=0.1,
                      alpha=0.9,
                      bordercolor=NA,
                      legend_sigfigs=2){
  
  # Handle input ===============================================================
  if(is.logical(detailed)){
    ifelse(detailed, detailed <- "detailed", detailed <- "coarse")
  }
  
  # Read in the map from .rds format ===========================================
  smoovpath = local(smoovpath, envir=.smoov_env)
  shppath   = file.path(smoovpath,
                        paste0(paste(geo, year, detailed, class, sep="_"),
                               ".rds"))
  if(!file.exists(shppath)){
    stop(paste0("no file exists at ", shppath, 
                " Try other values for `year` `detailed` and `class`."))
  }
  shp <- readRDS(shppath)
  
  # Merge data =================================================================
  outlist = shp_data_merge(shp, data, id, value, subsetfips)
  shp = outlist[["shp"]]
  subset_logic = outlist[["subset_logic"]]
  
  # Create plots ===============================================================
  # Move Hawaii and Alaska
  # https://www.r-spatial.org/r/2018/10/25/ggplot2-sf-3.html
  if(class=="sf"){
    usa_coord    = ggplot2::coord_sf(crs=sf::st_crs(2163),
                                     xlim=c(-2500000, 2500000),
                                     ylim=c(-2300000, 730000))
    alaska_coord = ggplot2::coord_sf(crs=sf::st_crs(3467),
                                     xlim=c(-2400000, 1600000),
                                     ylim=c(-200000, 2500000),
                                     expand=FALSE, datum=NA)
    hawaii_coord = ggplot2::coord_sf(crs=sf::st_crs(4135),
                                     xlim=c(-161, -154),
                                     ylim=c(18, 23),
                                     expand=FALSE, datum=NA)

    if(is.null(value) & is.null(data)){
      basemap = ggplot2::ggplot() +
        ggplot2::geom_sf(data=shp, lwd=linesize) +
        ggplot2::theme_void()
    }else{
      if(gradient=="redblue"){
        colors = c("#990000",
                   "#ff3030",
                   "#FFD699",
                   "#007777",
                   "#005566")
      }
      
      if(gradient_dir==-1){
        colors = rev(colors)
      }
      
      
      values = .Internal(
        do.call(what="$", args=list(shp, value), envir=parent.frame())
      )
      value_quant = quantile(values, probs=gradient_breaks, na.rm=TRUE)
      value_range = unitquant(values, probs=gradient_breaks)
      basemap = ggplot2::ggplot() +
        ggplot2::geom_sf(data=shp,
                         ggplot2::aes(fill=get(value), color=get(value)),
                         alpha=alpha,
                         size=linesize) +
        ggplot2::scale_fill_gradientn(name="",
                             values=value_range,
                             colours=colors,
                             na.value="#CCCCCC",
                             labels=round(value_quant,legend_sigfigs),
                             breaks=value_quant) +
        ggplot2::scale_color_gradientn(name="",
                                      values=value_range,
                                      colours=colors,
                                      na.value="#CCCCCC",
                                      guide=FALSE) +
        ggplot2::theme_void()
    }
    
    # Use different zoom levels depending on subsetting
    # TODO: subset in shp_data_merge set for HI and AK
    
    # Alaska
    if(subset_logic[2]){
      sublog = .Internal(substr(shp$fips, 1L, 2L))=="02"
      if(is.null(value) & is.null(data)){
        alaska = ggplot2::ggplot() +
          ggplot2::geom_sf(data=subset(shp, subset=sublog),lwd=linesize) +
          ggplot2::theme_void() +
          alaska_coord
      }else{
        alaska = ggplot2::ggplot() +
          ggplot2::geom_sf(data=subset(shp$data, subset=sublog),
                           mapping=ggplot2::aes(fill=get(value), color=get(value)),
                           alpha=alpha,
                           size=linesize) +
          ggplot2::scale_fill_gradientn(name="",
                                        values=value_range,
                                        colours=colors,
                                        na.value="#CCCCCC",
                                        labels=round(value_quant,legend_sigfigs),
                                        breaks=ifelse(subset_logic[1],
                                                      NULL,
                                                      value_quant)) +
          ggplot2::scale_color_gradientn(name="",
                                         values=value_range,
                                         colours=colors,
                                         na.value="#CCCCCC",
                                         guide=FALSE) +
          ggplot2::theme_void() +
          alaska_coord
      }
    }else if(subset_logic[1]){
      alaska = ggplot2::ggplot() + ggplot2::theme_void()
    }
    
    # Hawaii
    if(subset_logic[3]){
      sublog = .Internal(substr(shp$fips, 1L, 2L))=="15"
      if(is.null(value) & is.null(data)){
        hawaii = ggplot2::ggplot() +
          ggplot2::geom_sf(data=subset(shp, subset=sublog),lwd=linesize) +
          ggplot2::theme_void() +
          hawaii_coord
      }else{
        hawaii = ggplot2::ggplot() +
          ggplot2::geom_sf(data=subset(shp$data, subset=sublog),
                           mapping=ggplot2::aes(fill=get(value), color=get(value)),
                           alpha=alpha,
                           size=linesize) +
          ggplot2::scale_fill_gradientn(name="",
                                        values=value_range,
                                        colours=colors,
                                        na.value="#CCCCCC",
                                        labels=round(value_quant,legend_sigfigs),
                                        breaks=ifelse(subset_logic[1],
                                                      NULL,
                                                      value_quant)) +
          ggplot2::scale_color_gradientn(name="",
                                         values=value_range,
                                         colours=colors,
                                         na.value="#CCCCCC",
                                         guide=FALSE) +
          ggplot2::theme_void() +
          hawaii_coord
      }
    }else if(subset_logic[1]){
      hawaii = ggplot2::ggplot() + ggplot2::theme_void()
    }
    # All US states
    if(subset_logic[1]){
      basemap = basemap + usa_coord
    }
    
    # Return ggplot2 object based on subset logic
    #    1. If just HI and AK are plotted (TODO)
    #    2. If just AK is plotted
    #    3. If just HI is plotted
    if(!subset_logic[1] & subset_logic[2] & !subset_logic[3]){
      return(alaska)
    }
    if(!subset_logic[1] & !subset_logic[2] & subset_logic[3]){
      return(hawaii)
    }
    
    if(subset_logic[1]){
      alaska = alaska +
        ggplot2::theme(legend.position="none")
      hawaii = hawaii +
        ggplot2::theme(legend.position="none")
      return(
        basemap + 
          ggplot2::annotation_custom(
            grob = ggplot2::ggplotGrob(alaska),
            xmin = -2750000,
            xmax = -2750000 + (1600000 - (-2400000))/2.5,
            ymin = -2450000,
            ymax = -2450000 + (2500000 - 200000)/2.5
          ) +
          ggplot2::annotation_custom(
            grob = ggplot2::ggplotGrob(hawaii),
            xmin = -1250000,
            xmax = -1250000 + (-154 - (-161))*120000,
            ymin = -2450000,
            ymax = -2450000 + (23 - 18)*120000
          ) +
          ggplot2::theme(legend.position=c(0.05,0.9),
                         legend.justification=c(0.05, 0.9),
                         legend.key.size = grid::unit(1.5, "cm"),
                         legend.key.width = grid::unit(0.5,"cm"))
      )
    }else{
      return(
        basemap + ggplot2::theme(legend.key.size = grid::unit(1.5, "cm"),
                                 legend.key.width = grid::unit(0.5,"cm"))
          
      )
    }
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
                                              fill=get(value))) +
               ggplot2::geom_polygon())
    }
  }
}
