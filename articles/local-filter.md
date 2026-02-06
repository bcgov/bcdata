# Update to \`filter()\` behaviour in bcdata v0.4.0

This vignette describes a change in
[bcdata](https://bcgov.github.io/bcdata/) v0.4.0 related to using
locally-executed functions in a
[`filter()`](https://bcgov.github.io/bcdata/reference/filter.md) query
with
[`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md):

When using
[`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md)
with [`filter()`](https://bcgov.github.io/bcdata/reference/filter.md),
many functions are translated to a query plan that is passed to and
executed on the server - this includes the CQL Geometry predicates such
as `INTERESECTS()`,
[`CROSSES()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md),
[`BBOX()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
etc, as well as many base R functions. However you sometimes want to
include a function call in your
[`filter()`](https://bcgov.github.io/bcdata/reference/filter.md)
statement which should be evaluated locally - i.e., it’s an R function
(often an [sf](https://r-spatial.github.io/sf/) function) with no
equivalent function on the server. Prior to version 0.4.0,
[bcdata](https://bcgov.github.io/bcdata/) did a reasonable (though not
perfect) job of detecting R functions inside a
[`filter()`](https://bcgov.github.io/bcdata/reference/filter.md)
statement that needed to be evaluated locally. In order to align with
recommended best practices for [dbplyr](https://dbplyr.tidyverse.org/)
backends, as of v0.4.0, function calls that are to be evaluated locally
now need to be wrapped in [`local()`](https://rdrr.io/r/base/eval.html).

For example, say we want to create a bounding box around two points and
use that box to perform a spatial filter on the remote dataset, to give
us just the set of local greenspaces that exist within that bounding
box.

``` r
library(sf)
library(bcdata)

two_points <- st_sfc(st_point(c(1164434, 368738)),
                     st_point(c(1203023, 412959)),
                     crs = 3005)
```

Previously, we could just do this, with
[`sf::st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html)
embedded in the call:

``` r
bcdc_query_geodata("local-and-regional-greenspaces") %>%
  filter(BBOX(st_bbox(two_points, crs = st_crs(two_points))))
```

    ## Error:
    ## ! Error : Cannot translate a <sfc_POINT> object to SQL.
    ## ℹ Do you want to force evaluation in R with (e.g.) `!!x` or `local(x)`?

However you must now use [`local()`](https://rdrr.io/r/base/eval.html)
to force local evaluation of
[`st_bbox()`](https://r-spatial.github.io/sf/reference/st_bbox.html) on
your machine in R, before it is translated into a query plan to be
executed on the server:

``` r
bcdc_query_geodata("local-and-regional-greenspaces") %>%
  filter(BBOX(local(st_bbox(two_points, crs = st_crs(two_points)))))
```

    ## Querying 'local-and-regional-greenspaces' record
    ## • Using collect() on this object will return 1236 features and 19 fields
    ## • At most six rows of the record are printed here
    ## ────────────────────────────────────────────────────────────────────────────────────────────────────
    ## Simple feature collection with 6 features and 19 fields
    ## Geometry type: POLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: 1187080 ymin: 409342.1 xmax: 1191300 ymax: 410578
    ## Projected CRS: NAD83 / BC Albers
    ## # A tibble: 6 × 20
    ##   id      LOCAL_REG_GREENSPACE…¹ PARK_NAME PARK_TYPE PARK_PRIMARY_USE REGIONAL_DISTRICT MUNICIPALITY
    ##   <chr>                    <int> <chr>     <chr>     <chr>            <chr>             <chr>       
    ## 1 WHSE_B…                   8423 Lillian … Local     Park             Capital           North Saani…
    ## 2 WHSE_B…                   8422 Nymph Po… Local     Park             Capital           North Saani…
    ## 3 WHSE_B…                   8447 H.M.S. P… Local     Park             Capital           North Saani…
    ## 4 WHSE_B…                   8434 Wain Park Local     Park             Capital           North Saani…
    ## 5 WHSE_B…                   8446 Prentice… Local     Park             Capital           North Saani…
    ## 6 WHSE_B…                   8448 <NA>      Local     Park             Capital           North Saani…
    ## # ℹ abbreviated name: ¹​LOCAL_REG_GREENSPACE_ID
    ## # ℹ 13 more variables: CIVIC_NUMBER <int>, CIVIC_NUMBER_SUFFIX <chr>, STREET_NAME <chr>,
    ## #   LATITUDE <dbl>, LONGITUDE <dbl>, WHEN_UPDATED <date>, WEBSITE_URL <chr>,
    ## #   LICENCE_COMMENTS <chr>, FEATURE_AREA_SQM <dbl>, FEATURE_LENGTH_M <dbl>, OBJECTID <int>,
    ## #   SE_ANNO_CAD_DATA <chr>, geometry <POLYGON [m]>

There is another illustration in the [“querying spatial data
vignette”](https://bcgov.github.io/bcdata/articles/efficiently-query-spatial-data-in-the-bc-data-catalogue.html#a-note-about-using-local-r-functions-in-constructing-filter-queries).
