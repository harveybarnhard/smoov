#' Simple mapping tool
#'
#' @param geo 
#'     Character string; Provide level of map geography e.g. county.
#'     See details.
#' @param data
#'     Dataframe; ID columns matching the level of geography. See details.
#' @param value
#'     character; Name of the column in `data` with which a
#'     choropleth is created. If no column is provided, a map of boundaries
#'     is produced. If more than one value is inputted, a facetted map is
#'     created.
#' @param id
#'     character; "fips" by default.
#'     Name of the column in `data` that provides the relevant
#'     geography identifier (e.g. FIPS code).
#' @param bins
#'     integer; 5 by default.
#' @param year
#'     integer; Currently either 2000 or 2010. Year of census geography. The
#'     most recent year by default.
#' @param detailed
#'     logical; FALSE by default. If TRUE, then  more detailed geographies are
#'     used when available. See details.
#' @param class
#'     `"sp"` or `"sf"`; `"sf"` by default. See details.
#' @param ...
#'     Optional parameters depending on choice of `shape`. See details.
#' @return 
#'     Output will be a `ggplot` base layer onto which any `ggplot` layer may
#'     be added. 
#' @export

smoov = function(geo,
                 data=NULL,
                 value=NULL,
                 id="fips",
                 bins=5,
                 year=2010,
                 detailed=FALSE,
                 class="sf",
                 states=NULL,
                 counties=NULL,
                 tracts=NULL){
  
  # Obtain smoov filepath and make sure environment is loaded ==================
  if(is.null(options("smoovpath"))){
    smoovpath = file.path(find.package("smoov"), "smoov_mapfiles")
  }else{
    smoovpath = file.path(options("smoovpath")$smoovpath, "smoov_mapfiles")
  }
  envpath = file.path(smoovpath, "smoov_env.rds")
  if(!exists(".smoov_env")){
    if(!file.exists(envpath)){
      stop("smoov environment not found in ", smoovpath, ". ",
           "Try running `smoov_setup() first.")
    }else{
      # Load smoov environment
      .smoov_env <<- readRDS(envpath)
    }
  }
  
  # Handle input ===============================================================
  # Allow for unconventional input of geo to work
  shape = smoov::geo_alias[geo_alias$alias==geo,]$name
  if(length(shape)==0){
    stop(paste0(geo, " is not a mappable geography with smoov."))
  }
  
  # Convert subset codes to standardized fips codes
  subfips = standardize_geo(state=states, county=counties, tract=tracts)
  # Load shapefile, merge on data, and create base plot
  return(smoov_plot(geo=shape, data, value, year, detailed, class, subfips))
}

#TODO: create cache feature for when many plots are being made
