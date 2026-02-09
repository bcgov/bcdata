# Query data from the B.C. Web Feature Service

Queries features from the B.C. Web Feature Service. See
[`bcdc_tidy_resources()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_tidy_resources.md) -
if a resource has a value of `"wms"` in the `format` column it is
available as a Web Feature Service, and you can query and download it
using `bcdc_query_geodata()`. The response will be paginated if the
number of features is greater than that allowed by the server. Please
see
[`bcdc_options()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_options.md)
for defaults and more information.

## Usage

``` r
bcdc_query_geodata(record, crs = 3005)
```

## Arguments

- record:

  either a `bcdc_record` object (from the result of
  [`bcdc_get_record()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_get_record.md)),
  a character string denoting the name or ID of a resource (or the URL)
  or a BC Geographic Warehouse (BCGW) name.

  It is advised to use the permanent ID for a record or the BCGW name
  rather than the human-readable name to guard against future name
  changes of the record. If you use the human-readable name a warning
  will be issued once per session. You can silence these warnings
  altogether by setting an option:
  `options("silence_named_get_data_warning" = TRUE)` - which you can set
  in your .Rprofile file so the option persists across sessions.

- crs:

  the epsg code for the coordinate reference system. Defaults to `3005`
  (B.C. Albers). See https://epsg.io.

## Value

A `bcdc_promise` object. This object includes all of the information
required to retrieve the requested data. In order to get the actual data
as an `sf` object, you need to run
[`collect()`](https://bcgov.github.io/bcdata/dev/reference/collect-methods.md)
on the `bcdc_promise`.

## Details

Note that this function doesn't actually return the data, but rather an
object of class `bcdc_promise`, which includes all of the information
required to retrieve the requested data. In order to get the actual data
as an `sf` object, you need to run
[`collect()`](https://bcgov.github.io/bcdata/dev/reference/collect-methods.md)
on the `bcdc_promise`. This allows further refining the call to
`bcdc_query_geodata()` with
[`filter()`](https://bcgov.github.io/bcdata/dev/reference/filter.md)
and/or
[`select()`](https://bcgov.github.io/bcdata/dev/reference/select.md)
statements before pulling down the actual data as an `sf` object with
[`collect()`](https://bcgov.github.io/bcdata/dev/reference/collect-methods.md).
See examples.

## Examples

``` r
# \donttest{
# Returns a bcdc_promise, which can be further refined using filter/select:
try(
  res <- bcdc_query_geodata("bc-airports", crs = 3857)
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

# To obtain the actual data as an sf object, collect() must be called:
try(
  res <- bcdc_query_geodata("bc-airports", crs = 3857) %>%
    filter(PHYSICAL_ADDRESS == 'Victoria, BC') %>%
    collect()
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

# To query based on partial matches, use %LIKE%:
try(
  res <- bcdc_query_geodata("bc-airports") %>%
    filter(PHYSICAL_ADDRESS %LIKE% 'Vict%')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

# To query using %IN%
try(
  res <- bcdc_query_geodata("bc-airports") %>%
    filter(
      AIRPORT_NAME %IN%
        c(
          "Victoria Harbour (Camel Point) Heliport",
          "Victoria Harbour (Shoal Point) Heliport"
        )
    ) %>%
    collect()
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached


try(
  res <- bcdc_query_geodata("groundwater-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == "108") %>%
    select(WELL_TAG_NUMBER, INTENDED_WATER_USE) %>%
    collect()
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

## A moderately large layer
try(
  res <- bcdc_query_geodata("bc-environmental-monitoring-locations")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  res <- bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
    filter(PERMIT_RELATIONSHIP == "DISCHARGE")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached


## A very large layer
try(
  res <- bcdc_query_geodata("terrestrial-protected-areas-representation-by-biogeoclimatic-unit")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

## Using a BCGW name
try(
  res <- bcdc_query_geodata("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [openmaps.gov.bc.ca]:
#> Failed to connect to openmaps.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }
```
