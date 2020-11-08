#' Simple mapping tool
#'
#' @param smoovpath
#'     Folder that contains shapefile folders and the smoov folder. If the smoov
#'     folder and shapefiles do not already exist, then \code{smoov_setup()}
#'     will create the folder

smoov_setup = function(smoovpath){
  envpath = file.path(smoovpath, "smoov", "smoov_env.rds")
  if(!file.exists(envpath)){
    # Create smoov environment
    dir.create(file.path(options("smoovpath")$smoovpath, "smoov"),
               showWarnings=FALSE)
    .smoov_env = new.env()
    # Add smoov path to environment
    assign("smoovpath", file.path(smoovpath, "smoov"), envir=.smoov_env)
    # TODO add default theme to environment
    saveRDS(.smoov_env, envpath)
  }else{
    # Load smoov environment
    .smoov_env = readRDS(envpath)
  }
}
