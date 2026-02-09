# Select columns from bcdc_query_geodata() call

Similar to a
[`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
call, this allows you to select which columns you want the Web Feature
Service to return. A key difference between
[`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html) and
`bcdata::select` is the presence of "sticky" columns that are returned
regardless of what columns are selected. If any of these "sticky"
columns are selected only "sticky" columns are return.
`bcdc_describe_feature` is one way to tell if columns are sticky in
advance of issuing the Web Feature Service call.

See
`dplyr::`[`select`](https://dplyr.tidyverse.org/reference/select.html)
for details.

## Usage

``` r
# S3 method for class 'bcdc_promise'
select(.data, ...)
```

## Arguments

- .data:

  object of class `bcdc_promise` (likely passed from
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_query_geodata.md))

- ...:

  One or more unquoted expressions separated by commas. See details.

## Methods (by class)

- `select(bcdc_promise)`: select.bcdc_promise

## Examples

``` r
# \donttest{
try(
  feature_spec <- bcdc_describe_feature("bc-airports")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  ## Columns that can selected:
  feature_spec[feature_spec$sticky == TRUE,]
)
#> Error in eval(expr, envir) : object 'feature_spec' not found

## Select columns
try(
  res <- bcdc_query_geodata("bc-airports") %>%
    select(DESCRIPTION, PHYSICAL_ADDRESS)
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

## Select "sticky" columns
try(
  res <- bcdc_query_geodata("bc-airports") %>%
    select(LOCALITY)
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }

```
