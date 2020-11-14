# Set libraries
library(smoov)
library(ggplot2)
library(data.table)

# Set outpath for figures
outpath = "C:/Users/hab737/GitHub/smoov/examples"

# Plot all US counties =========================================================
data(county_commute)
data = data.table(data)
data[, commuters := pop_workers - commute_stayhome]
data[commuters<0, commuters:=NA]
data[, commute_active := (commute_bcycle + commute_walked+1)/(commuters+1)]
county_commute = active_commuting(county_commute)

# Create fips code and plot
county_commute[, fips := create_fips(state, county)]
smoov("counties", data=county_commute, value="commute_active")
ggsave(file.path(outpath, "county_example.png"))

# Plot Chicago surroundings ====================================================
data(tract_commute)
tract_commute = active_commuting(tract_commute)
tract_commute[, fips := create_fips(state, county, tract)]

# Plot Chicago surroundings + formatted title
chi = smoov(geo="tracts", data=tract_commute, value="commute_active",
      states=c(17,17,17,18), counties=c(31,43,197,89)) +
  labs(title="% of Active Commuters Relative to National Commuting Population",
       subtitle="Cook (IL), DuPage (IL), Will (IL), and Lake (IN) Counties") +
  theme(plot.title = element_text(size=20, face="bold", hjust = 0.5),
        plot.subtitle = element_text(size=15, face="bold", hjust = 0.5),
        legend.position=c(0.9,0.8),
        legend.justification=c(0.9, 0.8))
ggsave(file.path(outpath, "tract_example.png"), plot=chi)

library(osmdata)
med_streets <- sf::st_bbox(chi$data)%>%
  osmdata::opq()%>%
  osmdata::add_osm_feature(key = "place", value = c("city")) %>%
  osmdata::osmdata_sf()


labellayer = ggrepel::geom_text_repel(
  data = med_streets$osm_multipolygons,
  aes(label=name, geometry=geometry),
  stat="sf_coordinates",
  min.segment.length=0,
  fontface="bold",
  segment.color=NA
)

chi = chi+labellayer
