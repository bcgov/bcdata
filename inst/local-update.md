Update to `filter()` behaviour in `{bcdata}`
================

A (very niche) head’s up for a breaking change in the next `{bcdata}`
release (v0.4.0):

When using `bcdc_query_geodata()` with `filter()`, you sometimes want to
include a function call in your `filter()` statement which should be
evaluated locally - i.e., it’s an R function, not a function to be
executed on the server. Previously {bcdata} did a reasonable (though not
perfect) job of detecting R functions inside a `filter()` statement that
needed to be evaluated locally. In order to align with recommended best
practices for {dbplyr} backends, function calls that are to be evaluated
locally now need to be wrapped in `local()`.

For example, say we want to create a bounding box around two points and
use that box to to perform a spatial filter on the remote dataset, to
give us just the set of local greenspaces that exist within that
bounding box.

``` r
library(sf)
library(bcdata)

two_points <- st_sfc(st_point(c(1164434, 368738)),
                     st_point(c(1203023, 412959)),
                     crs = 3005)
```

Previously, we could just do this, with `sf::st_bbox()` embedded in the
call:

``` r
bcdc_query_geodata("local-and-regional-greenspaces") %>%
  filter(BBOX(st_bbox(two_points, crs = st_crs(two_points))))
```

    Error: Unable to process query. Did you use a function that should be evaluated locally? If so, try wrapping it in 'local()'.

However you must now use `local()` to force evaluation of `st_bbox()` on
your machine in R, before it is translated into a query to be executed
on the server:

``` r
bcdc_query_geodata("local-and-regional-greenspaces") %>%
  filter(BBOX(local(st_bbox(two_points, crs = st_crs(two_points)))))
```

    Querying 'local-and-regional-greenspaces' record
    • Using collect() on this object will return 1154 features and 19 fields
    • At most six rows of the record are printed here
    ────────────────────────────────────────────────────────────────────────────────
    Simple feature collection with 6 features and 19 fields
    Geometry type: POLYGON
    Dimension:     XY
    Bounding box:  xmin: 1200113 ymin: 385903.5 xmax: 1202608 ymax: 386561.8
    Projected CRS: NAD83 / BC Albers
    # A tibble: 6 × 20
      id     LOCAL…¹ PARK_…² PARK_…³ PARK_…⁴ REGIO…⁵ MUNIC…⁶ CIVIC…⁷ CIVIC…⁸ STREE…⁹
      <chr>    <int> <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>  
    1 WHSE_…    3347 Konuks… Local   Green … Capital Distri… <NA>    <NA>    <NA>   
    2 WHSE_…    3304 <NA>    Local   Trail   Capital Distri… <NA>    <NA>    <NA>   
    3 WHSE_…    3380 <NA>    Local   Water … Capital Distri… <NA>    <NA>    <NA>   
    4 WHSE_…    3369 <NA>    Local   Water … Capital Distri… <NA>    <NA>    <NA>   
    5 WHSE_…    3453 <NA>    Local   Water … Capital Distri… <NA>    <NA>    <NA>   
    6 WHSE_…    3361 <NA>    Local   Trail   Capital Distri… <NA>    <NA>    <NA>   
    # … with 10 more variables: LATITUDE <dbl>, LONGITUDE <dbl>,
    #   WHEN_UPDATED <date>, WEBSITE_URL <chr>, LICENCE_COMMENTS <chr>,
    #   FEATURE_AREA_SQM <dbl>, FEATURE_LENGTH_M <dbl>, OBJECTID <int>,
    #   SE_ANNO_CAD_DATA <chr>, geometry <POLYGON [m]>, and abbreviated variable
    #   names ¹​LOCAL_REG_GREENSPACE_ID, ²​PARK_NAME, ³​PARK_TYPE, ⁴​PARK_PRIMARY_USE,
    #   ⁵​REGIONAL_DISTRICT, ⁶​MUNICIPALITY, ⁷​CIVIC_NUMBER, ⁸​CIVIC_NUMBER_SUFFIX,
    #   ⁹​STREET_NAME

This is also explained and illustrated in the development version of the
[package
documentation](https://bcgov.github.io/bcdata/dev/articles/efficiently-query-spatial-data-in-the-bc-data-catalogue.html#a-note-about-using-local-r-functions-in-constructing-filter-queries).
