#' Simple mapping tool
#'
#' @param smoovpath
#'     Folder that contains shapefile folders and the smoov folder. If the smoov
#'     folder and shapefiles do not already exist, then \code{smoov_setup()}
#'     will create the folder

smoov_setup = function(smoovpath){
  envpath = file.path(smoovpath, "smoov", "smoov_env.rds")
  if(!file.exists(envpath)){
    # If the smoov environment file does not exist, create the smoov folder
    # if it does not yet exist, then create and save the smoov environment
    dir.create(file.path(smoovpath, "smoov"), showWarnings=FALSE)
    .smoov_env = new.env()
    assign("smoovpath", file.path(smoovpath), envir=.smoov_env)
    saveRDS(.smoov_env, envpath)
    
    # Create 
  }else{
    # If the smoov environment file does exist, load it
    .smoov_env = readRDS(envpath)
  }
  
}
