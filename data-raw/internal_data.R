# Create lookup table for aliases of geography levels
geo_table = data.frame(
  name = c("states",
           "states",
           "counties",
           "counties",
           "tracts2000",
           "tracts2000",
           "tracts2010",
           "tracts2010",
           "tracts2010",
           "tracts2010"),
  alias = c("states",
            "state",
            "counties",
            "county",
            "tracts2000",
            "tract2000",
            "tracts2010",
            "tract2010",
            "tracts",
            "tract")
)

usethis::use_data(
  geo_table,
  internal=TRUE
)

# For using this: smoov::geo_table
