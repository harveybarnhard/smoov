# Create state, county, and tract files for each state and the nation as a whole

# Function to load tract maps
# Columns to pull from map files: cols[cb][year]
cols = list()
cols[["colsTRUE2000"]]  = c("AREA", "STATE", "COUNTY", "TRACT")
cols[["colsFALSE2000"]] = c("ALAND00", "CTIDFP00")
cols[["colsTRUE2010"]]  = c("CENSUSAREA", "STATE", "COUNTY", "TRACT")
cols[["colsFALSE2010"]] = c("ALAND10", "GEOID10")
load_merge_tracts = function(cb, yr, cl, outname){
  coliter = cols[[paste0("cols", cb, yr)]]
  if(cl=="sf"){
    coliter = c(coliter, "geometry")
  }
  for(i in 1:length(state.abb)){
    tractmap = tigris::tracts(state=state.abb[i],
                              cb=cb,
                              year=yr,
                              class=cl)[, coliter]
    # Concatenate local fips to create state-county-tract fips code
    if(cb){
      tractmap$fips = paste0(tractmap$STATE, tractmap$COUNTY, tractmap$TRACT)
      if(yr==2000){
        tractmap = tractmap[, c("AREA", "fips")]
      }else if(yr==2010){
        tractmap = tractmap[, c("CENSUSAREA", "fips")]
      }
    }
    
    # Rename columns
    if(cl=="sf"){
      colnames(tractmap) = c("area", "fips", "geometry")
    }else if(cl=="sp"){
      colnames(tractmap@data) = c("area", "fips")
    }
    
    # Save into global environment
    if(i==1){
      assign(outname, tractmap, envir=.GlobalEnv)
    }else{
      assign(outname, rbind(get(outname), tractmap), envir=.GlobalEnv)
    }
  }
  
  # If class=="sp" then the file must be fortified into a data.frame format
  if(cl=="sp"){
    suppressMessages(shp_map <- ggplot2::fortify(get(outname)))
    shp_dt = get(outname)@data
    shp_dt$id = rownames(shp_dt)
    rownames(shp_dt) = c()
    shp_map = merge(shp_map, shp_dt, by="id", all.x=TRUE)
    shp_map$id = c()
    assign(outname, shp_map, envir=.GlobalEnv)
    gc()
  }
}

# Function to load county maps
load_counties = function(cb, yr, cl, outname){
  # Suppress warnings about CRS object 
  suppressWarnings(countymap <- tigris::counties(cb=cb, year=yr, class=cl))
  assign(outname, countymap, envir=.GlobalEnv)
}

# Wrapper for state and county loading
geo_wrapper = function(vec, outpath){
  # Arguments
  geo     = as.character(vec[1])
  cb      = as.logical(vec[2]=="coarse")
  yr      = as.integer(vec[3])
  cl      = as.character(vec[4])
  outname = as.character(vec[5])
  # Load the shapefiles, handling errors/warnings so that this doesn't
  # interrupt the process of loading all relevant packages
  garbage = tryCatch({
    message("Creating: ", outname)
    # Save as .rds file unless file already exists
    filepath = file.path(outpath, paste0(outname, ".rds"))
    if(file.exists(filepath)){
      warning(outname, " already exists in ", outpath) 
    }else{
      if(geo=="tracts"){
        load_merge_tracts(cb, yr, cl, outname)
      }else if(geo=="counties"){
        load_counties(cb, yr, cl, outname)
      }
      saveRDS(get(outname), file=filepath)
      rm(outname)
      gc()
    }
  }, error = function(cond){
    # Handle Errors by skipping over any shapefiles that produce error
    message(outname, " failed to build with error ", cond)
  }, warning=function(cond){
    # Handle warnings
    message(outname, " produced warning: ", cond)
  })
}

# Load state abbreviations, adding DC
data(state)
state.abb = c(state.abb, "DC")

# Find Cartesian product of values to loop through
target = expand.grid(geo   = c("tracts", "counties"),
                     cb    = c("coarse", "detailed"),
                     yr    = c(2000, 2010),
                     class = c("sf", "sp"),
                     stringsAsFactors=FALSE)
target$outname = paste(target$geo,
                       target$yr,
                       target$cb,
                       target$cl,
                       sep="_")

# Find path to save objects
if(is.null(options("smoovpath"))){
  outpath = file.path(find.package("smoov"), "mapfiles")
}else{
  outpath = file.path(options("smoovpath")$smoovpath, "mapfiles")
}
dir.create(outpath, showWarnings=FALSE)

#TODO Only load data when necessary (do this by removing rows of target)
garbage = apply(target, 1, geo_wrapper, outpath=outpath)






