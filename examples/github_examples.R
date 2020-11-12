# Set libraries
library(smoov)
library(ggplot2)
library(httr)
library(jsonlite)

# Set outpath for figures


# Plot all US counties
smoov("counties")

# Plot Chicago surroundings
smoov(geo="tracts", states=17, counties=c(31,43))

# Plot Chicago surroundings + formatted title
smoov("tracts", states=c(17,17,18), counties=c(31,43,89)) +
  labs(title="Cook and DuPage Counties (IL), Lake County (IN)") +
  theme(plot.title = element_text(size=20, face="bold", hjust = 0.5))

