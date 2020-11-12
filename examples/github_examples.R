# Set libraries
library(smoov)
library(ggplot2)
library(data.table)

# Set outpath for figures

# Function to calculate relative active commuting ==============================
active_commuting = function(data){
  data = data.table(data)
  data[, commuters := pop_workers - commute_stayhome]
  data[commuters<0, commuters:=NA]
  data[, commute_active := (commute_bcycle + commute_walked+1)/(commuters+1)]
  data[, active := log(commute_active)]
  
  # Impute any missing value with average and subtract weighted mean from total
  data[, active := log(commute_active)]
  mean_act = data[!is.na(active), sum(commuters*active)/sum(commuters)]
  data[is.na(active), active:=mean_act]
  data[, active := active - mean_act]
  
  # Winsorize at the national 95th and 75th percentile
  act95 = quantile(data$active, probs=0.95)
  act05 = quantile(data$active, probs=0.05)
  data[active>act95, active:=act95]
  data[active<act05, active:=act05]
  return(data)
}

# Plot all US counties =========================================================
data(county_commute)
county_commute = active_commuting(county_commute)

# Create fips code and plto
county_commute[, fips := create_fips(state, county)]
smoov("counties", data=county_commute, value="active")

# Plot Chicago surroundings ====================================================
data(tract_commute)
tract_commute = active_commuting(tract_commute)
tract_commute[, fips := create_fips(state, county, tract)]
# Plot Chicago surroundings + formatted title
smoov(geo="tracts", data=tract_commute, value="active",
      states=c(17,17,18), counties=c(31,43,89)) +
  labs(title="% of Active Commuters Relative to National Commuting Population",
       subtitle="Cook and DuPage Counties (IL), Lake County (IN)") +
  theme(plot.title = element_text(size=20, face="bold", hjust = 0.5),
        plot.subtitle = element_text(size=15, face="bold", hjust = 0.5),
        legend.position=c(0.2,0.2),
        legend.justification=c(0.2, 0.2))

