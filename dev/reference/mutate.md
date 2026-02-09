# Throw an informative error when attempting mutate on a `bcdc_promise` object

The CQL syntax to generate WFS calls does not current allow arithmetic
operations. Therefore this function exists solely to generate an
informative error that suggests an alternative approach to use mutate
with bcdata

See
`dplyr::`[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)
for details.

## Usage

``` r
# S3 method for class 'bcdc_promise'
mutate(.data, ...)
```

## Arguments

- .data:

  object of class `bcdc_promise` (likely passed from
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_query_geodata.md))

- ...:

  One or more unquoted expressions separated by commas. See details.

## Methods (by class)

- `mutate(bcdc_promise)`: mutate.bcdc_promise

## Examples

``` r
# \donttest{

## Mutate columns
try(
  res <- bcdc_query_geodata("bc-airports") %>%
    mutate(LATITUDE * 100)
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }
```
