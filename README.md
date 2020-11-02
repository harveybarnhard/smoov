# smoov
Simple Mapping Of Our Vicinities

## Setup

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
.smoov_env = new.env()
assign("smoovpath", "C:/Users/Harvey/shapefiles", envir=.smoov_env)
```
replacing `C:/Users/Harvey/shapefiles` with the exact filepath
where you want your smoov shapefiles to be loaded and stored.
This creates a hidden environment called `.smoov_env`[^1].
so that all the objects that make up the smoov package don't clutter up
your environment if you are working interactively. Now save the `.Rprofile`
file and exit. You then must restart R prior to using smoov.

[^1]: adding a `.` before an object hides that object from your environment list in RStudio
