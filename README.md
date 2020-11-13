# smoov
This package intended smooths the process of mapping common objects like states, counties,
and census tracts. Mapping in R oftentimes involves multiple packages with varying syntaxes, leading
to downright ugly code, and downright ugly maps.
This package enables **s**imple **m**apping **o**f **o**ur **v**icinities.

For mapping purposes, this package relies heavily upon `ggplot2` while the actual
downloading of shapefiles is facilitated by the package `tigris`.

# Example

`smoov` makes maps  with sensible, visually appealing defaults for making maps
with United States Census geographies. I have a dataset in `data.table` format
called `county_commute` with three relevant variables:

* `state`: state FIPS code in integer format
* `county`: county FIPS code in integer format
* `active`: % of workers who commute by walking or cycling subtracted
            by the national % of workers who commute by walking or cycling

In order to create a county-level map, this is all I need to do.
```r
# Load data and create active commuter column using pre-made function
data(county_commute)
county_commute = active_commuting(county_commute)

# Create FIPS code and plot!
county_commute[, fips := create_fips(state, county)]
smoov("counties", data=county_commute, value="active")
```

![](examples/county_example.png)

The first step uses `smoov::create_fips` to properly concatenate state and
county FIPS codes (or state, county, and tract codes), regardless of string
length. The second step plots at the level of `"counties` using the
column `"active"` in the dataset `county_commute`.

Let's say I'm interested in tract-level data in and around Chicago, IL. To produce
such maps, this would usually require several slow, multi-line steps:

1. Load shapefile(s).
2. Merge shapefiles (tract shapefiles are often
   separated by state).
3. Merge tract-level data onto shapefiles.
4. Subset data appropriately.
5. Map
6. Modify map aesthetics

With `smoov` however, steps one through five, and parts of step six
are simplified to _one line_.
First, the level of geography is provided with the `geo` parameter.
Next, optional subsetting takes place using state, county and tract
[FIPS](https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt#:~:text=FIPS%20codes%20are%20numbers%20which,to%20which%20the%20county%20belongs.)
codes. The object produced by `smoov()` is simply a `ggplot2` object, so additional layers
can be added using the ggplot2 syntax:

```r
# Load data and create active commuter column
data(tract_commute)
tract_commute = active_commuting(tract_commute)
tract_commute[, fips := create_fips(state, county, tract)]

# Plot Chicago surroundings and beautify using ggplot layers
smoov(geo="tracts", data=tract_commute, value="active",
      states=c(17,17,17,18), counties=c(31,43,197,89)) +
  labs(title="% of Active Commuters Relative to National Commuting Population",
       subtitle="Cook (IL), DuPage (IL), Will (IL), and Lake (IN) Counties") +
  theme(plot.title = element_text(size=20, face="bold", hjust = 0.5),
        plot.subtitle = element_text(size=15, face="bold", hjust = 0.5),
        legend.position=c(0.8,0.8),
        legend.justification=c(0.8, 0.8))
```

![](examples/tract_example.png)

## Setup

It's easiest to install this package by running the following line of code in the R
console.

```r
devtools::install_github("harveybarnhard/smoov")
```

Before using `smoov`, the shapefiles must be downloaded and converted to .rds files for
efficient loading and use by `smoov` functions. The function `smoov_setup()` serves
just this purpose.

For reproducability, this step should be placed at the top of the project file where
you are loading all of your R packages, e.g.

```r
library(data.table)
library(smoov)
smoov_setup(load_mapfiles=TRUE)
```
