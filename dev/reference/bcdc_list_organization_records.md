# Retrieve organization information for B.C. Data Catalogue

Returns a tibble of organizations or records. Organizations can be
viewed here: https://catalogue.data.gov.bc.ca/organizations or accessed
directly from R using `bcdc_list_organizations`

## Usage

``` r
bcdc_list_organizations()

bcdc_list_organization_records(organization)
```

## Arguments

- organization:

  Name of the organization

## Functions

- `bcdc_list_organizations()`:

## Examples

``` r
# \donttest{
try(
  bcdc_list_organization_records('bc-stats')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }
```
