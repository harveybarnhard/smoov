# Function to load tract maps ==================================================
load_merge_tracts = function(cb, yr, cl, outname){
  # Columns to pull from map files: cols[cb][year]
  cols = list()
  cols[["colsTRUE2000"]]  = c("AREA", "STATE", "COUNTY", "TRACT")
  cols[["colsFALSE2000"]] = c("ALAND00", "CTIDFP00")
  cols[["colsTRUE2010"]]  = c("CENSUSAREA", "STATE", "COUNTY", "TRACT")
  cols[["colsFALSE2010"]] = c("ALAND10", "GEOID10")
  coliter = cols[[paste0("cols", cb, yr)]]
  if(cl=="sf"){
    coliter = c(coliter, "geometry")
  }
  for(i in 1:length(state.abb)){
    suppressWarnings(tractmap <- tigris::tracts(state=state.abb[i],
                                                cb=cb,
                                                year=yr,
                                                class=cl)[, coliter])
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
      mastermap = tractmap
    }else{
      mastermap = rbind(mastermap, tractmap)
    }
  }
  
  # If class=="sp" then the file must be fortified into a data.frame format
  if(cl=="sp"){
    suppressMessages(shp_map <- ggplot2::fortify(mastermap))
    shp_dt = mastermap@data
    shp_dt$id = rownames(shp_dt)
    rownames(shp_dt) = c()
    shp_map = merge(shp_map, shp_dt, by="id", all.x=TRUE)
    shp_map$id = c()
    mastermap = shp_map
    gc()
  }
  return(mastermap)
}

# Function to load county maps =================================================
load_counties = function(cb, yr, cl, outname){
  # Suppress warnings about CRS object 
  suppressWarnings(countymap <- tigris::counties(cb=cb, year=yr, class=cl))
  
  # Concatenate local fips to create state-county fips code
  countymap$fips = paste0(countymap$STATE, countymap$COUNTY)
  if(cb){
    countymap$fips = paste0(countymap$STATE, countymap$COUNTY)
    if(yr==2000){
      countymap = countymap[, c("AREA", "fips")]
    }else if(yr==2010){
      countymap = countymap[, c("CENSUSAREA", "fips")]
    }
  }
  
  # Rename columns
  if(cl=="sf"){
    colnames(countymap) = c("area", "fips", "geometry")
  }else if(cl=="sp"){
    colnames(countymap@data) = c("area", "fips")
  }
  
  
  # If class=="sp" then the file must be fortified into a data.frame format
  if(cl=="sp"){
    suppressMessages(shp_map <- ggplot2::fortify(countymap))
    shp_dt = countymap@data
    shp_dt$id = rownames(shp_dt)
    rownames(shp_dt) = c()
    shp_map = merge(shp_map, shp_dt, by="id", all.x=TRUE)
    shp_map$id = c()
  }
  return(countymap)
}

# Function to load state maps ==================================================
load_states = function(cb, yr, cl, outname){
  # suppress warnings about CRS object
  suppressWarnings(statemap <- tigris::states(cb=cb, year=yr, class=cl))
  
  # Concatenate local fips to create state-county-tract fips code
  statemap$fips = statemap$STATE
  if(cb){
    if(yr==2000){
      statemap = statemap[, c("AREA", "fips")]
    }else if(yr==2010){
      statemap = statemap[, c("CENSUSAREA", "fips")]
    }
  }
  
  # Rename columns
  if(cl=="sf"){
    colnames(statemap) = c("area", "fips", "geometry")
  }else if(cl=="sp"){
    colnames(statemap@data) = c("area", "fips")
  }
  
  # If class=="sp" then the file must be fortified into a data.frame format
  if(cl=="sp"){
    suppressMessages(shp_map <- ggplot2::fortify(statemap))
    shp_dt = statemap@data
    shp_dt$id = rownames(shp_dt)
    rownames(shp_dt) = c()
    shp_map = merge(shp_map, shp_dt, by="id", all.x=TRUE)
    shp_map$id = c()
  }
  return(statemap)
}

# Wrapper for state and county loading =========================================
geo_loader = function(vec, outpath){
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
        geomap = load_merge_tracts(cb, yr, cl, outname)
      }else if(geo=="counties"){
        geomap = load_counties(cb, yr, cl, outname)
      }else if(geo=="states"){
        geomap = load_states(cb, yr, cl, outname)
      }
      saveRDS(geomap, file=filepath)
    }
  }, error = function(cond){
    # Handle Errors by skipping over any shapefiles that produce error
    message(outname, " failed to build with error ", cond)
  }, warning=function(cond){
    # Handle warnings
    message(outname, " produced warning: ", cond)
  })
}