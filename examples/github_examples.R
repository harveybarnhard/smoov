# Set libraries
library(smoov)
library(ggplot2)
library(data.table)

# Set outpath for figures
outpath = "C:/Users/hab737/GitHub/smoov/examples"

# Plot all US counties =========================================================
actcom = function(pop, stayhome, bcycle, walk){
  # Calculate proportion of active commuters
  commuters = pop
  commuters[commuters<0] = NA
  active = 100*(bcycle + walk+1)/(commuters+1)
  
  # Winsorize
  quants = quantile(active, probs=c(0.05,0.95), na.rm=TRUE)
  active[active<quants[1]] = quants[1]
  active[active>quants[2]] = quants[2]
  return(
    active
  )
}

data(county_commute)
dtc = data.table(county_commute)
dtc = dtc[, active := actcom(pop_workers, commute_stayhome,
                             commute_bcycle, commute_walked)]

# Create fips code and plot
dtc[, fips := create_fips(state, county)]
usa = smoov("counties", data=dtc, value="active")
ggsave(file.path(outpath, "county_example.png"), plot=usa)

# Plot Boston surroundings =====================================================
data(tract_commute)
dtt = data.table(tract_commute)
dtt = dtt[, active := actcom(pop_workers, commute_stayhome,
                             commute_bcycle, commute_walked)]
dtt[, fips := create_fips(state, county, tract)]

# Plot Boston surroundings
east_MA =  c(1,5,17,21,23,25,027)
bos = smoov(geo="tracts", data=dtt, value="active", states=25, counties=east_MA)
ggsave(file.path(outpath, "tract_example1.png"), plot=bos)

# Plot Boston surroundings with titles and formatted legend
bos = bos +
  labs(title="Active Commuters in Eastern Massachusetts",
       subtitle="% of Commuters who Walk or Cycle by Census Tract") +
  theme(plot.title = element_text(size=20, face="bold", hjust = 0.5),
        plot.subtitle = element_text(size=15, face="bold", hjust = 0.5),
        legend.position=c(0.8,0.9),
        legend.justification=c(0.8, 0.9),
        legend.key.size = unit(1.5, "cm"),
        legend.key.width = unit(0.5,"cm"))
ggsave(file.path(outpath, "tract_example2.png"), plot=bos)

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
