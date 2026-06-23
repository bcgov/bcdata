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

- `bcdc_list_groups()`: List the available groups in the B.C. Data
  Catalogue.

## Examples

``` r
# \donttest{
try(
  bcdc_list_group_records('environmental-reporting-bc')
)
#> Group Description: 
#> Number of datasets: 32
#> # A tibble: 32 × 47
#>    author     author_email creator_user_id download_audience
#>    <chr>      <lgl>        <chr>           <chr>            
#>  1 018e9ef6-… NA           d0716cb8-7eb5-… Public           
#>  2 018e9ef6-… NA           018e9ef6-5356-… Public           
#>  3 d0716cb8-… NA           d0716cb8-7eb5-… Public           
#>  4 7c3cb269-… NA           7c3cb269-3653-… Public           
#>  5 7c3cb269-… NA           7c3cb269-3653-… Public           
#>  6 39990ef0-… NA           39990ef0-fa9a-… Public           
#>  7 d0716cb8-… NA           d0716cb8-7eb5-… NA               
#>  8 d0716cb8-… NA           d0716cb8-7eb5-… Public           
#>  9 d0716cb8-… NA           d0716cb8-7eb5-… Public           
#> 10 11389078-… NA           11389078-2e35-… Public           
#> # ℹ 22 more rows
#> # ℹ 43 more variables: id <chr>, isopen <lgl>,
#> #   license_id <chr>, license_title <chr>,
#> #   license_url <chr>, maintainer <lgl>,
#> #   maintainer_email <lgl>, metadata_created <chr>,
#> #   metadata_modified <chr>, metadata_visibility <chr>,
#> #   name <chr>, notes <chr>, num_resources <int>, …
# }
```
