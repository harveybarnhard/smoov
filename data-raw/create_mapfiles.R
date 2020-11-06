# Create state, county, and tract files for each state and the nation as a whole

# Function to load tract maps
load_merge_tracts = function(cb, year, class, outname){
  colsTRUE2000  = c("AREA", "STATE", "COUNTY", "TRACT")
  colsFALSE2000 = c("ALAND00", "CTIDFP00")
  colsTRUE2010  = c("CENSUSAREA", "STATE", "COUNTY", "TRACT")
  colsFALSE2010 = c("ALAND10", "GEOID10")
  newnames = c("area", "fips")
  for(i in 1:length(state.abb)){
    tractmap = tigris::tracts(state=state.abb[i],
                              cb=cb,
                              year=year,
                              class=class)[, get(paste0("cols", cb, year))]
    # Concatenate local fips to create state-county-tract fips code
    if(cb){
      tractmap$fips = paste0(tractmap$STATE, tractmap$COUNTY, tractmap$TRACT)
      if(year==2000){
        tractmap = tractmap[, c("AREA", "fips")]
      }else if(year==2010){
        tractmap = tractmap[, c("CENSUSAREA", "fips")]
      }
    }
    # Rename columns
    if(class=="sf"){
      colnames(tractmap) = newnames
    }else if(class=="sp"){
      colnames(tractmap@data) = newnames
    }
    # Save into global environment
    if(i==1){
      assign(outname, tractmap, envir=.GlobalEnv)
    }else{
      assign(outname, rbind(get(outname), tractmap), envir=.GlobalEnv)
    }
  }
}

# Function to load county maps
load_counties = function(cb, year, class, outname){
  countymap = tigris::counties(cb=coarse, year=yr, class=cl)
  assign(outname, countymap, envir=.GlobalEnv)
}

# Load state abbreviations, adding DC
data(state)
# state.abb = c(state.abb, "DC")
state.abb = "IN"

# Initialize vector of names of mapfiles to save
outnamevec = c()

for(geo in c("tracts", "counties")){
  for(yr in c(2000, 2010)){
    for(coarse in c(TRUE, FALSE)){
      for(cl in c("sf", "sp")){
        outname = paste0(geo, yr, coarse, cl)
        outnamevec = c(outnamevec, outname)
        # Handle tracts and counties differently
        if(geo=="tracts"){
          # Load each state's tracts one-by-one then bind them together
          load_merge_tracts(coarse, yr, cl, outname)
        }else if(geo=="counties"){
          load_counties(coarse, yr, cl, outname)
        }
      }
    }
  }
}

# #TODO figure out the best way to fortify for ggplot...this is slow
# 
# in_tracts_sp = tigris::tracts("IN", year=2000, class="sp")
# in_tracts_sp@data$id = rownames(in_tracts_sp@data)
# in_tracts_sp = merge(x=fortify(in_tracts_sp), y=in_tracts_sp@data, by="id")
# in_tracts_sf = tigris::tracts("IN", year=2000, class="sf")
# 
# random_data = data.table(in_tracts_sf[, c("CTIDFP00")])
# random_data[, geometry:=NULL] 
# random_data[, rando:= rnorm(nrow(random_data))]
# 
# merge_fort_sf = function(x, y){
#   temp = merge(x, y, by="CTIDFP00")
#   ggplot(temp) +
#     geom_sf(aes(fill=rando))
# }
# merge_fort_sp = function(x, y){
#   temp = merge(x=x, y=y, by="CTIDFP00")
#   ggplot(temp, aes(x=long, y=lat, group=group, fill=rando)) +
#     geom_polygon()
# }
# 
# microbenchmark::microbenchmark(
#   methodsf = merge_fort_sf(in_tracts_sf, random_data),
#   methodsp = merge_fort_sp(in_tracts_sp, random_data),
#   times=10
# )
