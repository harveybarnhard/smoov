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
#'     is produced. If more than one value is inputted, a faceted map is
#'     created.
#' @param id
#'     character; "fips" by default.
#'     Name of the column in `data` that provides the relevant
#'     geography identifier (e.g. FIPS code).
#' @param year
#'     integer; Currently either 2000 or 2010. Year of census geography. The
#'     most recent year by default.
#' @param detailed
#'     logical; FALSE by default. If TRUE, then  more detailed geographies are
#'     used when available
#' @param class
#'     `"sp"` or `"sf"`; `"sf"` by default.
#' @param ...
#'     Optional aesthetic parameters, subsetting parameters. See details below.
#' @return 
#'     Output will be a `ggplot` base layer onto which any `ggplot` layer may
#'     be added. 
#' @section Geographic Subsetting Parameters:
#' * `states`: Vector of state \href{https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code}{FIPS} codes.
#'   Character and numeric vectors allowed.
#' * `counties`: Vector of county \href{https://www.nrcs.usda.gov/wps/portal/nrcs/detail/national/home/?cid=nrcs143_013697}{FIPS} codes.
#'   Character and numeric vectors allowed. If length of `states` vector is
#'   longer than one, then `counties` vector must be of the same length.
#' @section Aesthetic Parameters:
#' * `gradient`: The color gradient to be plotted, currently only "redblue"
#' * `gradient_dir`: The direction the color gradient should go. Default is
#'   `1` for low values to get the first value of the gradient and
#'   `-1` is for low values to get the second value of the
#'   color gradient.
#' * `gradient_breaks`: A vector of five probabilities in \eqn{[0,1]^5}
#'   that define the quantiles of `values` that the gradient emphasizes.
#'   Defaults to `c(0,0.35,0.5,0.65,1)`
#' * `linesize`: The size of the borders of geographic units. Defaults to
#'   0.05 for plotting tracts, 0.1 for other levels of geography
#' * `alpha`: Transparency parameter for fill colors. 0 is completely
#'   transparent and 1 is completely opaque. Defaults to 0.9
#' * `bordercolor`: Color of geography borders
<<<<<<< Updated upstream
#'   transparent and 1 is completely opaque. Defaults to 0.9.
=======
#' 
>>>>>>> Stashed changes
#'     
#' @export

smoov = function(geo,
                 data=NULL,
                 value=NULL,
                 id="fips",
                 year=2010,
                 detailed=FALSE,
                 class="sf",
                 states=NULL,
                 counties=NULL,
                 tracts=NULL,
                 ...){
  
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
  shape = geo_alias[geo_alias$alias==geo,]$name
  if(length(shape)==0){
    stop(paste0(geo, " is not a mappable geography with smoov."))
  }
  
  # Convert subset codes to standardized fips codes
  subfips = create_fips(state=states, county=counties, tract=tracts)
  # Load shapefile, merge on data, and create base plot
  if(!is.null(data)){
    if(is.null(value)){
      stop("Must provided `value` if providing `data`")
    }
    inds = .Internal(do.call(what="$", args=list(data,id)))
    data = data[inds, c(id, value), drop=drop]
  }
  return(smoov_plot(geo=shape,
                    data=data,
                    value=value,
                    id=id,
                    year=year,
                    detailed=detailed,
                    class=class,
                    subsetfips=subfips,
                    ...))
}

#TODO: create cache feature for when many plots are being made
