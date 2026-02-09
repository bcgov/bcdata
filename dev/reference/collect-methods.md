# as_tibble

See
`tibble::`[`as_tibble`](https://tibble.tidyverse.org/reference/as_tibble.html)
for details.

After tuning a query, `collect()` is used to actually bring the data
into memory. This will retrieve an sf object into R. The `as_tibble()`
function can be used interchangeably with `collect` which matches
`dbplyr` behaviour.

See
`dplyr::`[`collect`](https://dplyr.tidyverse.org/reference/compute.html)
for details.

## Usage

``` r
# S3 method for class 'bcdc_promise'
collect(x, ...)

# S3 method for class 'bcdc_promise'
as_tibble(x, ...)
```

## Arguments

- x:

  object of class `bcdc_promise`

## Examples

``` r
# \donttest{
try(
  bcdc_query_geodata("bc-airports") %>%
    collect()
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_query_geodata("bc-airports") %>%
    as_tibble()
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }
```
