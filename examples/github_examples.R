# Set libraries
library(smoov)
library(ggplot2)
library(data.table)

# Set outpath for figures


# Plot all US counties
data(county_commute)
dt = data.table(county_commute)
dt[, public := sqrt(commute_public/pop_workers)]
dt[, fips := create_fips(state, county)]
smoov("counties", data=dt, value="public")

# Plot Chicago surroundings
data(tract_commute)
dt = data.table(tract_commute)
dt[, public := sqrt(commute_public/pop_workers)]
dt[, fips := create_fips(state, county, tract)]
smoov(geo="tracts", data=tract_commute, value="commute_car", states=17, counties=c(31,43))

# Plot Chicago surroundings + formatted title
smoov(geo="tracts", states=c(17,17,18), counties=c(31,43,89)) +
  labs(title="Cook and DuPage Counties (IL), Lake County (IN)") +
  theme(plot.title = element_text(size=20, face="bold", hjust = 0.5))

