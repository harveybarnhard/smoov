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
  # If class=="sp" then the file must be fortified
  if(cl=="sp"){
    assign
  }
}

# Function to load county maps
load_counties = function(cb, yr, cl, outname){
  countymap = tigris::counties(cb=cb, year=yr, class=cl)
  assign(outname, countymap, envir=.GlobalEnv)
}

# Wrapper for state and county loading
geo_wrapper = function(vec){
  geo = as.character(vec[1])
  cb  = as.logical(vec[2])
  yr  = as.integer(vec[3])
  cl  = as.character(vec[4])
  outname = vec[5]
  cat(geo, cb, yr, cl)
  if(geo=="tracts"){
    load_merge_tracts(cb, yr, cl, outname)
  }else if(geo=="counties"){
    load_counties(cb, yr, cl, outname)
  }
}

# Load state abbreviations, adding DC
data(state)
state.abb = c(state.abb, "DC")
#state.abb = "IN"

# Find cartesian product of values to loop through
target = expand.grid(geo   = c("tracts", "counties"),
                     cb    = c(TRUE, FALSE),
                     yr    = c(2000, 2010),
                     class = c("sf", "sp"),
                     stringsAsFactors=FALSE)
target$outname = paste0(target$geo,
                        target$yr,
                        target$cb,
                        target$cl)
apply(target, 1, geo_wrapper)
