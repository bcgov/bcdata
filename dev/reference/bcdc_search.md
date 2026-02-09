# Search the B.C. Data Catalogue

Search the B.C. Data Catalogue

## Usage

``` r
bcdc_search(
  ...,
  license_id = NULL,
  download_audience = NULL,
  res_format = NULL,
  sector = NULL,
  organization = NULL,
  groups = NULL,
  n = 100
)
```

## Arguments

- ...:

  search terms

- license_id:

  the type of license (see `bcdc_search_facets("license_id")`).

- download_audience:

  download audience (see `bcdc_search_facets("download_audience")`).
  Default `NULL` (all audiences).

- res_format:

  format of resource (see `bcdc_search_facets("res_format")`)

- sector:

  sector of government from which the data comes (see
  `bcdc_search_facets("sector")`)

- organization:

  government organization that manages the data (see
  `bcdc_search_facets("organization")`)

- groups:

  collections of datasets for a particular project or on a particular
  theme (see `bcdc_search_facets("groups")`)

- n:

  number of results to return. Default `100`

## Value

A list containing the records that match the search

## Examples

``` r
# \donttest{
try(
  bcdc_search("forest")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_search("regional district", res_format = "fgdb")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_search("angling", groups = "bc-tourism")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }
```
