## code to prepare `DATASET` dataset goes here

# trimmed down datasets to just AJWM (TOTAL POPULATION) and 
# AJXC variables (MEANS OF TRANSPORTATION TO WORK)
# TODO: Make this an extract with an API call rather than a manual download

# Local path to GitHub repo
smoovpath = "C:/Users/hab737/GitHub/smoov"

# Columns to keep
keep_cols = c("AJWME001",
              "AJXCE001",
              "AJXCE002",
              "AJXCE010",
              "AJXCE016",
              "AJXCE017",
              "AJXCE018",
              "AJXCE019",
              "AJXCE020",
              "AJXCE021")

# Descriptive names for columns to keep
new_names = c("pop_total",
              "pop_workers",
              "commute_car",
              "commute_public",
              "commute_taxi",
              "commute_mcycle",
              "commute_bcycle",
              "commute_walked",
              "commute_other",
              "commute_stayhome")

# Loop over geographies, loading and saving them as .Rda objects
for(geo in c("state", "county", "tract")){
  # Add column geography names in each iteration
  keep_cols = c(toupper(paste0(geo, "A")), keep_cols)
  if(geo=="tract"){
    ind = 5:length(keep_cols)
    keep_cols[ind] = gsub("E", "M", keep_cols[ind])
  }
  new_names = c(geo, new_names)
  # Read in dataset from .csv
  dt_geo = read.csv(file.path(smoovpath,
                              "data-raw",
                              paste0("nhgis_", geo, ".csv")))
  
  # Subset by and rename columns
  dt_geo = dt_geo[, colnames(dt_geo)%in%keep_cols]
  data.table::setnames(dt_geo, old=keep_cols, new=new_names)
  
  # Output as .rda file
  assign(paste0(geo ,"_commute"), dt_geo)
}
usethis::use_data(state_commute, overwrite = TRUE)
usethis::use_data(county_commute, overwrite = TRUE)
usethis::use_data(tract_commute, overwrite = TRUE)