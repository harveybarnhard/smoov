#' Helper function for smoov_setup.R

# Load county, tract, and state shapefiles
create_mapfiles = function(us_geos){
  # Load us tract, county, and state geographies ===============================
  if(us_geos==TRUE){
    # Load state abbreviations, adding DC
    data(state)
    state.abb = c(state.abb, "DC")
    
    # Find Cartesian product of values to loop through
    target = expand.grid(geo   = c("tracts", "counties", "states"),
                         cb    = c("coarse", "detailed"),
                         yr    = c(2000, 2010),
                         class = c("sf", "sp"),
                         stringsAsFactors=FALSE)
    target$outname = paste(target$geo,
                           target$yr,
                           target$cb,
                           target$cl,
                           sep="_")
    
    # Remove detailed county maps
    target = target[!(target$cb=="detailed" & target$geo=="counties"),]
    
    # Find path to save objects
    smoovpath = local(smoovpath, envir=.smoov_env)
    garbage = apply(target, 1, smoov::geo_loader, outpath=smoovpath)
    
    # Record successfully loaded filepaths in smoov environment
    files = list.files(path=smoovpath, pattern="*.rds")
    files = gsub(".rds$", "", files)
    files = intersect(files, target$outname)
    if(exists("mapfiles", envir=.smoov_env)){
      files = union(local(mapfiles, envir=.smoov_env), files)
    }
    assign("mapfiles", files, envir=.smoov_env)
  }
  
  # TODO: Load roads
  # if(roads==TRUE){
  #   
  # }
  
  # TODO: Load school districts
  # if(sch_districts==TRUE){
  #   
  # }
}