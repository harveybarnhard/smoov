# smoov
This is a package intended to smooth over the process of mapping common objects like states, counties,
and census tracts. This package enables **s**imple **m**apping **o**f **o**ur **v**icinities.

For mapping purposes, this package relies heavily upon `ggplot2` while the actual
downloading of packages is facilitated by the package `tigris`.

## Setup

Before using `smoov`, the shapefiles must be downloaded and converted to .rds files for
efficient loading and use by `smoov` functions. The function `smoov_setup()` serves
just this purpose.

For reproducability, this step should be placed at the top of the project file where
you are loading all of your r packages, e.g.

```r
library(data.table)
library(smoov)
smoov_setup()
```
