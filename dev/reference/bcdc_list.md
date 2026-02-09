# Return a full list of the names of B.C. Data Catalogue records

Return a full list of the names of B.C. Data Catalogue records

## Usage

``` r
bcdc_list()
```

## Value

A character vector of the names of B.C. Data Catalogue records

## Examples

``` r
# \donttest{
try(
  bcdc_list()
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }
```
