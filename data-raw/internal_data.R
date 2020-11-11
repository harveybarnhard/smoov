# Create lookup table for aliases of geography levels
geo_alias = data.frame(
  name = c("states",
           "states",
           "counties",
           "counties",
           "tracts",
           "tracts"),
  alias = c("states",
            "state",
            "counties",
            "county",
            "tracts",
            "tract")
)

usethis::use_data(
  geo_alias,
  internal=TRUE,
  overwrite=TRUE
)