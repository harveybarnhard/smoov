smoov_load = function(geo){
  if(!exists(".smoov_env")){
    stop("smoov environment does not exist")
  }
  shp = readRDS(
    file.path(
      local(smoovpath, envir=.smoov_env)
    )
  )
}

smoov_plot = function(){
  
}
