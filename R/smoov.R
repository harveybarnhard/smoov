#' Simple mapping tool
#'
#' @param geo 
#'     Character string; Provide level of map geography e.g. county.
#'     See details below for more information 
#' @param data
#'     Dataframe; ID columns matching the level of geography. See details.
#' @param value
#'     character; Name of the column in `data` with which a
#'     choropleth is created. If no column is provided, a map of boundaries
#'     is produced.
#' @param bins
#'     integer; 5 by default.
#' @param class
#'     `"sp"` or `"sf"`; `"sf"` by default. See details.
#' @param ...
#'     Optional parameters depending on choice of `shape`.
#' @export

smoov = function(geo, data, value=NA, bins=5, class="sf", ...){
  if(!exists(".smoov_env")){
    stop("smoov environment does not exist")
  }
  arguments = list(...)
  
  # Load shapefile and merge on data values
  smoov_load(geo, data, "sf") #TODO create smoov_load()
  
  # Plot shapefile
  smoov_plot(arguments) #TODO create smoov_plot()
}
