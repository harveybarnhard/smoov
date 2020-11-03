# smoov
This is a package intended to smooth over the process of mapping common objects like states, counties,
and census tracts. This package enables **s**imple **m**apping **o**f **o**ur **v**icinities.

## Setup

### Setup for interactive use
| :warning: **If you are NOT running your code interactively mode**: See section setup for non-interactive use |
| --- |

The first thing you'll want to do is edit your `.Rprofile` file to add the
path you want the smoov package to use to store the relevant shapefiles.

The easiest way to edit your `.Rprofile` is to run the following command in
RStudio.

```r
usethis::edit_r_profile()
```

Running this command pulls up your `.Rprofile` file. On a new line, enter the
following code,

```r
library(smoov)
smoov::smoov_setup("C:/Users/Harvey/shapefiles")
```
replacing `C:/Users/Harvey/shapefiles` with the exact filepath
where you want your smoov shapefiles to be loaded and stored.

Now save the `.Rprofile` file and exit. You then must restart R prior to using smoov.

### Setup for non-interactive use
