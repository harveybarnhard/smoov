#' Add border layers to plot
#' 
#' @param geo
#'     String. May include: "tracts", "counties", or
#'    "states"
#' @param line_color
#'     String. Color of borders. Default is "black"
#' @param line_alpha
#'     Numeric in [0,1]. Transparency of borders.0 for completely transparent
#'     and 1 for completely opaque
#' @param line_size
#'     Numeric. Default is 0.1
#' @param fill_color
#'     String. Color of fill within borders. Default is NA (i.e. transparent)
#' @param fill_alpha
#'     String. Transparency of fill within borders. Default is 0.5
#' @param ...
#'     Optional subsetting parameters and shapefile options. See `?smoov`
#'     
#' @export
smoov_border = function(geo=NULL,
                        line_color="black",
                        line_size=0.1,
                        line_alpha=1,
                        fill_color=NA,
                        fill_alpha=0.5,
                        states=NULL,
                        counties=NULL,
                        tracts=NULL,
                        year=2010,
                        detailed="coarse",
                        class="sf"){
  # Handle input ===============================================================
  if(is.null(geo)){
    stop("Must provide value for `geo`. Current acceptable values ",
         "are 'tracts', 'counties', and 'states' ")
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
  
  # Subset map =================================================================
  subfips = create_fips(state=states, county=counties, tract=tracts)
  
  outlist = shp_data_merge(shp=shp, subfips=subfips)
  subset_logic = outlist[["subset_logic"]]
  return(
    ggplot2::geom_sf(data=outlist[["shp"]],
                     color=ggplot2::alpha(line_color, line_alpha),
                     size=line_size,
                     fill=ggplot2::alpha(fill_color, fill_alpha))
  )
  
}