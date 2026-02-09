# Retrieve group information for B.C. Data Catalogue

Returns a tibble of groups or records. Groups can be viewed here:
https://catalogue.data.gov.bc.ca/group or accessed directly from R using
`bcdc_list_groups`

## Usage

``` r
bcdc_list_groups()

bcdc_list_group_records(group)
```

## Arguments

- group:

  Name of the group

## Functions

- `bcdc_list_groups()`:

## Examples

``` r
# \donttest{
try(
  bcdc_list_group_records('environmental-reporting-bc')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }
```
