# smoov
This is a package intended to smooth over the process of mapping common objects like states, counties,
and census tracts. Mapping in R is oftentimes involves multiple packages with varying syntaxes, leading
to downright ugly code, and downright ugly maps.
This package enables **s**imple **m**apping **o**f **o**ur **v**icinities.

For mapping purposes, this package relies heavily upon `ggplot2` while the actual
downloading of shapefiles is facilitated by the package `tigris`.

# Example

`smoov` makes maps  with sensible, visually appealing defaults for making maps
for United States Census geographies.

Here's how you plot a map of all US counties.

```r
smoov("counties")
```

Let's say I'm interested in tract-level data in and around Chicago, IL. To produce
such maps, this would usually require several slow, multi-line steps:

1. Load shapefile(s)
2. Merge shapefiles and relevant data onto shapefile (tract shapefiles are often
   separated by state.

With `smoov` however, this process is simpliefied to _one line_.
First, the level of geography is provided with the `geo` parameter.
Next, optional subsetting takes place using state, county and tract
[FIPS](https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt#:~:text=FIPS%20codes%20are%20numbers%20which,to%20which%20the%20county%20belongs.)
codes.

The following line of code maps all tracts in Cook and DuPage Counties, Illinois
(FIPS codes 17031 and 17043).

```r
smoov(geo="tracts", states=17, counties=c(31,43))
```

The object produced by `smoov()` is simply a `ggplot2` object, so additional layers
can be added using the ggplot2 syntax:

```r
smoov("tracts", states=c(17,17,18), counties=c(31,43,89)) +
  labs(title="Cook and DuPage Counties (IL)") +
  theme(plot.title = element_text(size=20, face="bold", hjust = 0.5))
```

## Setup

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
