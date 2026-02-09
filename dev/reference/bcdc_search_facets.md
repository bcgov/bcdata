# Get the valid values for a facet (that you can use in [`bcdc_search()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_search.md))

Get the valid values for a facet (that you can use in
[`bcdc_search()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_search.md))

## Usage

``` r
bcdc_search_facets(
  facet = c("license_id", "download_audience", "res_format", "publish_state",
    "organization", "groups")
)
```

## Arguments

- facet:

  the facet(s) for which to retrieve valid values. Can be one or more
  of:
  `"license_id", "download_audience", "res_format", "publish_state", "organization", "groups"`

## Value

A data frame of values for the selected facet

## Examples

``` r
# \donttest{
try(
  bcdc_search_facets("download_audience")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_search_facets("res_format")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10001 ms: Timeout was reached
# }
```
