#' Simple mapping tool
#' @param load_mapfiles logical; FALSE by default. If TRUE, loads and prepares
#'     mapfiles for use in the `smoov()` function. If only certain geographies
#'     wish to be loaded, use instead `load_us_geos`, `load_roads`, or
#'     `load_sch_districts`. 
#' @param load_us_geos logical; FALSE by default. If TRUE then loads US tracts,
#'     counties, and states.
#' @param load_roads logical; FALSE by default. If TRUE then loads US roads
#'     for counties of the top 25 US cities by population
#'     
#' @export
smoov_setup = function(load_mapfiles=FALSE,
                       load_us_geos=FALSE,
                       load_roads=FALSE){
  # Create smoov path
  if(is.null(options("smoovpath"))){
    smoovpath = file.path(find.package("smoov"), "smoov_mapfiles")
  }else{
    smoovpath = file.path(options("smoovpath")$smoovpath, "smoov_mapfiles")
  }
  
  # Create smoov directory if it does not already exist
  garbage = tryCatch({
    dir.create(smoovpath)
  }, warning = function(cond){
    message("Filepath for smoov directory: ", smoovpath)
  }, finally = function(cond){
    message("Filepath for smoov directory: ", smoovpath)
  })
  rm(garbage)
  
  # Create smoov environment if it does not already exist
  envpath = file.path(smoovpath, "smoov_env.rds")
  if(!file.exists(envpath)){
    .smoov_env = new.env()
    # Add smoov path to environment
    assign("smoovpath", smoovpath, envir=.smoov_env)
    # TODO add default theme to environment
    saveRDS(.smoov_env, envpath)
  }else{
    # Load smoov environment
    .smoov_env = readRDS(envpath)
  }
  
  # Load mapfiles, ignoring mapfiles that have not already been loaded
  if(load_mapfiles){
    create_mapfiles(us_geos=TRUE)
    # TODO: create_roads()
    # TODO: create_districts
  }else if(load_us_geos){
    create_mapfiles(us_geos=TRUE)
  }
  
  # Save .smoov_env in case anything has changed
  saveRDS(.smoov_env, envpath)
}
