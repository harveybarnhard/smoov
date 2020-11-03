#' Simple mapping tool
#'
#' @param geo 
#'     Character string; Provide level of map geography e.g. county.
#'     See details below for more information 
#' @param data
#'     Dataframe; ID columns matching the level of geography. See details
#'     for more information on column naming
#' @param value
#'     character; Name of the column in `data` with which a
#'     choropleth is created.
#' @param bins
#'     integer; 5 by default.
#' @param ...
#'     Optional parameters depending on choice of `shape`.

smoov = function(geo, data, value , bins=5, ...){
  if(!exists(".smoov_env")){
    stop("smoov environment does not exist")
  }
  arguments = list(...)
  
  # Load shapefile and merge on data values
  smoov_load(geo, data) #TODO create smoov_load()
  
  # Plot shapefile
  smoov_plot(arguments) #TODO create smoov_plot()
}
