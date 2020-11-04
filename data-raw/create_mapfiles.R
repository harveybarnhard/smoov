# Create state, county, and tract files for each state and the nation as a whole

# Create function to load tract maps
tract_maps = function(st, yr, coarse){
  trpoly = tigris::tracts(state=st, year=yr, cb=coarse)
}

# Load state abbreviations, adding DC
data(state)

# Detailed tracts
tract2000_list = lapply(c(state.abb, "DC"),
                        function(x) tract_maps(x, yr=2000, coarse=FALSE))
tract2010_list = lapply(c(state.abb, "DC"),
                        function(x) tract_maps(x, yr=2010, coarse=FALSE))

# Non-detailed tracts
tract2000_list = lapply(c(state.abb, "DC"),
                        function(x) tract_maps(x, yr=2000, coarse=TRUE))
tract2010_list = lapply(c(state.abb, "DC"),
                        function(x) tract_maps(x, yr=2010, coarse=TRUE))

# Detailed counties
counties2010   = tigris::counties(cb=FALSE, year=2010)

# Non-detailed counties
counties2010   = tigris::counties(cb=TRUE, year=2010)