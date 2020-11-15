# trimmed down datasets to just AJWM (TOTAL POPULATION) and 
# AJXC variables (MEANS OF TRANSPORTATION TO WORK)

# Local path to GitHub repo
smoovpath = "C:/Users/hab737/GitHub/smoov"

# Extract dataset ==============================================================
# This requires an API key. Mine happens to be stored in my .Renviron file.
# For information on how to perform API requests from IPUMS,
# see the following link:
# https://developer.ipums.org/docs/workflows/create_extracts/nhgis_data/
my_key = Sys.getenv("NHGIS")

url <- "https://api.ipums.org/metadata/nhgis/datasets/2014_2018_ACS5a?version=v1"
result <- GET(url, add_headers(Authorization = my_key))
res_df <- content(result, "parsed", simplifyDataFrame = TRUE)

url <- "https://api.ipums.org/extracts/?product=nhgis&version=v1"
mybody <- '

{
  "datasets": {
    "2014_2018_ACS5a": {
      "breakdown_values": ["bs32.ge00"],
      "data_tables": [
        "B01003", "B08301"
      ],
      "geog_levels": [
        "state","county","tract"
      ]
    }
  },
  "data_format": "csv_no_header",
  "description": "Pull for smoov example",
  "breakdown_and_data_type_layout": "single_file"
}

'
mybody_json <- jsonlite::fromJSON(mybody, simplifyVector = FALSE)
result <- httr::POST(url,
                     httr::add_headers(Authorization = my_key),
                     body = mybody_json,
                     encode = "json",
                     httr::verbose())
res_df <- httr::content(result, "parsed", simplifyDataFrame = TRUE)
my_number <- res_df$number


# Check status
getpath = paste0("https://api.ipums.org/extracts/",
                 my_number,
                 "?product=nhgis&version=v1")
data_extract_status_res <- httr::GET(getpath,
                                     httr::add_headers(Authorization = my_key))
des_df = httr::content(data_extract_status_res, "parsed", simplifyDataFrame=TRUE)

# Download files when ready
zip_file <- file.path(smoovpath, "data-raw","NHGIS_tables.zip")
# download.file(des_df$download_links$table_data, zip_file)
download.file("https://live.nhgis.datadownload.ipums.org/web/extracts/nhgis/1509035/nhgis0008_csv.zip",
              zip_file)

# Modify dataset for use in examples ===========================================

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
                              paste0("commute_",geo, ".csv")))
  
  # Subset by and rename columns
  dt_geo = dt_geo[, colnames(dt_geo)%in%keep_cols]
  data.table::setnames(dt_geo, old=keep_cols, new=new_names)
  
  # Output as .rda file
  saveRDS(dt_geo, file=file.path(smoovpath, "data-raw", paste0(geo, "_commute.rds")))
  assign(paste0(geo ,"_commute"), dt_geo)
  
}