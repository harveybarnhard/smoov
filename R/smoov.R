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
#'     character; Name of the column in `data` that provides the relevant
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
#' @export

smoov = function(geo,
                 data,
                 value=NA,
                 id,
                 bins=5,
                 year=2010,
                 detailed=FALSE,
                 class="sf",
                 ...){
  if(!exists(".smoov_env")){
    stop("smoov environment does not exist")
  }
  arguments = list(...)
  
  # Load shapefile and merge on data values
  smoov_load(geo, data, value, year, detailed, class)
}
