# Show SQL and URL used for Web Feature Service request from B.C. Data Catalogue

Display Web Feature Service query CQL

See
`dplyr::`[`show_query`](https://dplyr.tidyverse.org/reference/explain.html)
for details.

## Usage

``` r
# S3 method for class 'bcdc_promise'
show_query(x, ...)

# S3 method for class 'bcdc_sf'
show_query(x, ...)
```

## Arguments

- x:

  object of class bcdc_promise or bcdc_sf

## Methods (by class)

- `show_query(bcdc_promise)`: show_query.bcdc_promise

- `show_query(bcdc_sf)`: show_query.bcdc_promise

## Examples

``` r
# \donttest{
try(
  bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
    filter(PERMIT_RELATIONSHIP == "DISCHARGE") %>%
    show_query()
)
#> <url>
#> <body>
#> SERVICE: WFS VERSION: 2.0.0 REQUEST: GetFeature
#>  outputFormat: application/json typeNames:
#>  WHSE_ENVIRONMENTAL_MONITORING.EMS_MONITORING_LOCN_TYPES_SVW
#>  SRSNAME: EPSG:3005 CQL_FILTER:
#>  ("PERMIT_RELATIONSHIP" = 'DISCHARGE')
#> 
#> <full query url>
#> https://openmaps.gov.bc.ca/geo/pub/wfs?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&outputFormat=application%2Fjson&typeNames=WHSE_ENVIRONMENTAL_MONITORING.EMS_MONITORING_LOCN_TYPES_SVW&SRSNAME=EPSG%3A3005&CQL_FILTER=%28%22PERMIT_RELATIONSHIP%22%20%3D%20%27DISCHARGE%27%29
  # }

# \donttest{
try(
  air <- bcdc_query_geodata("bc-airports") %>%
    collect()
)

try(
  show_query(air)
)
#> <url>
#> <body>
#> SERVICE: WFS VERSION: 2.0.0 REQUEST: GetFeature
#>  outputFormat: application/json typeNames:
#>  WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW SRSNAME:
#>  EPSG:3005
#> 
#> <full query url>
#> https://openmaps.gov.bc.ca/geo/pub/wfs?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature&outputFormat=application%2Fjson&typeNames=WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW&SRSNAME=EPSG%3A3005
# }
```
