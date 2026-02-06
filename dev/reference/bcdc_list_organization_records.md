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
#> # A tibble: 88 × 48
#>    author     author_email creator_user_id download_audience
#>  * <chr>      <lgl>        <chr>           <chr>            
#>  1 NA         NA           40a48d33-5a6c-… Public           
#>  2 NA         NA           40a48d33-5a6c-… Public           
#>  3 NA         NA           bcd0e79c-e403-… Public           
#>  4 d0716cb8-… NA           d0716cb8-7eb5-… Public           
#>  5 NA         NA           b3245224-9d10-… Public           
#>  6 NA         NA           b3245224-9d10-… Public           
#>  7 NA         NA           40a48d33-5a6c-… Public           
#>  8 NA         NA           40a48d33-5a6c-… Public           
#>  9 NA         NA           40a48d33-5a6c-… Public           
#> 10 NA         NA           40a48d33-5a6c-… Public           
#> # ℹ 78 more rows
#> # ℹ 44 more variables: id <chr>, isopen <lgl>,
#> #   license_id <chr>, license_title <chr>,
#> #   license_url <chr>, maintainer <lgl>,
#> #   maintainer_email <lgl>, metadata_created <chr>,
#> #   metadata_modified <chr>, metadata_visibility <chr>,
#> #   name <chr>, notes <chr>, num_resources <int>, …
# }
```
