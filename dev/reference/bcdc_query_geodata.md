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

# To obtain the actual data as an sf object, collect() must be called:
try(
  res <- bcdc_query_geodata("bc-airports", crs = 3857) %>%
    filter(PHYSICAL_ADDRESS == 'Victoria, BC') %>%
    collect()
)

# To query based on partial matches, use %LIKE%:
try(
  res <- bcdc_query_geodata("bc-airports") %>%
    filter(PHYSICAL_ADDRESS %LIKE% 'Vict%')
)

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
#> Error : There was an issue sending this WFS request
#> ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
#> Request:
#>   URL: https://openmaps.gov.bc.ca/geo/pub/wfs
#>   POST fields:
#>     resultType=hits&SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&outputFormat=application%2Fjson&typeNames=WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW&SRSNAME=EPSG%3A3005&CQL_FILTER=%28%22AIRPORT_NAME%22%20IN%20%27Victoria%20Harbour%20%28Camel%20Point%29%20Heliport%27%2C%20%27Victoria%20Harbour%20%28Shoal%20Point%29%20Heliport%27%29
#>   Content-Type: application/x-www-form-urlencoded
#>   Accept-Encoding: gzip, deflate
#>   Accept: application/json, text/xml, application/xml, */*
#>   User-Agent: https://github.com/bcgov/bcdata
#> Response:
#>   status: HTTP/1.1 400 Bad Request
#>   content-type: application/xml
#>   transfer-encoding: chunked
#>   x-ratelimit-limit-second: 60000
#>   x-ratelimit-remaining-second: 59996
#>   ratelimit-limit: 60000
#>   ratelimit-remaining: 59996
#>   ratelimit-reset: 1
#>   vary: Origin
#>   vary: Access-Control-Request-Method
#>   vary: Access-Control-Request-Headers
#>   date: Fri, 10 Jul 2026 21:52:44 GMT
#>   server: uvicorn
#>   content-encoding: gzip
#>   x-kong-upstream-latency: 7
#>   x-kong-proxy-latency: 0
#> 


try(
  res <- bcdc_query_geodata("groundwater-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == "108") %>%
    select(WELL_TAG_NUMBER, INTENDED_WATER_USE) %>%
    collect()
)

## A moderately large layer
try(
  res <- bcdc_query_geodata("bc-environmental-monitoring-locations")
)

try(
  res <- bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
    filter(PERMIT_RELATIONSHIP == "DISCHARGE")
)


## A very large layer
try(
  res <- bcdc_query_geodata("terrestrial-protected-areas-representation-by-biogeoclimatic-unit")
)

## Using a BCGW name
try(
  res <- bcdc_query_geodata("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
)
# }
```
