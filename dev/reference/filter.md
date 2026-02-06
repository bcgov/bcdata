# Filter a query from bcdc_query_geodata()

Filter a query from Web Feature Service using dplyr methods. This
filtering is accomplished lazily so that the full sf object is not read
into memory until
[`collect()`](https://bcgov.github.io/bcdata/dev/reference/collect-methods.md)
has been called.

See
`dplyr::`[`filter`](https://dplyr.tidyverse.org/reference/filter.html)
for details.

## Usage

``` r
# S3 method for class 'bcdc_promise'
filter(.data, ...)
```

## Arguments

- .data:

  object of class `bcdc_promise` (likely passed from
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_query_geodata.md))

- ...:

  Logical predicates with which to filter the results. Multiple
  conditions are combined with `&`. Only rows where the condition
  evaluates to `TRUE` are kept. Accepts normal R expressions as well as
  any of the special [CQL geometry
  functions](https://bcgov.github.io/bcdata/dev/reference/cql_geom_predicates.md)
  such as
  [`WITHIN()`](https://bcgov.github.io/bcdata/dev/reference/cql_geom_predicates.md)
  or
  [`INTERSECTS()`](https://bcgov.github.io/bcdata/dev/reference/cql_geom_predicates.md).
  If you know `CQL` and want to write a `CQL` query directly, write it
  enclosed in quotes, wrapped in the
  [`CQL()`](https://bcgov.github.io/bcdata/dev/reference/CQL.md)
  function. e.g., `CQL("ID = '42'")`.

  If your filter expression contains calls that need to be executed
  locally, wrap them in [`local()`](https://rdrr.io/r/base/eval.html) to
  force evaluation in R before the request is sent to the server.

## Methods (by class)

- `filter(bcdc_promise)`: filter.bcdc_promise

## Examples

``` r
# \donttest{
try(
  crd <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()
)

try(
  ret1 <- bcdc_query_geodata("bc-wildfire-fire-perimeters-historical") %>%
    filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
    collect()
)

# Use local() to force parts of your call to be evaluated in R:
try({
  # Create a bounding box around two points and use that to filter
  # the remote data set
  library(sf)
  two_points <- st_sfc(st_point(c(1164434, 368738)),
                     st_point(c(1203023, 412959)),
                     crs = 3005)

  # Wrapping the call to `st_bbox()` in `local()` ensures that it
  # is executed in R to make a bounding box that is then sent to
  # the server for the filtering operation:
  res <- bcdc_query_geodata("local-and-regional-greenspaces") %>%
    filter(BBOX(local(st_bbox(two_points, crs = st_crs(two_points))))) %>%
    collect()
})
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2()
#> is TRUE
# }
```
