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
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
  # }

# \donttest{
try(
  air <- bcdc_query_geodata("bc-airports") %>%
    collect()
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  show_query(air)
)
#> Error in eval(expr, envir) : object 'air' not found
# }
```
