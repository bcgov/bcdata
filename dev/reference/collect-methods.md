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
#> Simple feature collection with 451 features and 41 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 405790.2 ymin: 367957.6 xmax: 1796772 ymax: 1688614
#> Projected CRS: NAD83 / BC Albers
#> # A tibble: 451 × 42
#>    id          CUSTODIAN_ORG_DESCRI…¹ BUSINESS_CATEGORY_CL…²
#>  * <chr>       <chr>                  <chr>                 
#>  1 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  2 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  3 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  4 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  5 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  6 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  7 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  8 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  9 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#> 10 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#> # ℹ 441 more rows
#> # ℹ abbreviated names: ¹​CUSTODIAN_ORG_DESCRIPTION,
#> #   ²​BUSINESS_CATEGORY_CLASS
#> # ℹ 39 more variables: BUSINESS_CATEGORY_DESCRIPTION <chr>,
#> #   OCCUPANT_TYPE_DESCRIPTION <chr>, SOURCE_DATA_ID <chr>,
#> #   SUPPLIED_SOURCE_ID_IND <chr>, AIRPORT_NAME <chr>,
#> #   DESCRIPTION <chr>, PHYSICAL_ADDRESS <chr>, …

try(
  bcdc_query_geodata("bc-airports") %>%
    as_tibble()
)
#> Simple feature collection with 451 features and 41 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 405790.2 ymin: 367957.6 xmax: 1796772 ymax: 1688614
#> Projected CRS: NAD83 / BC Albers
#> # A tibble: 451 × 42
#>    id          CUSTODIAN_ORG_DESCRI…¹ BUSINESS_CATEGORY_CL…²
#>  * <chr>       <chr>                  <chr>                 
#>  1 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  2 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  3 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  4 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  5 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  6 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  7 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  8 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  9 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#> 10 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#> # ℹ 441 more rows
#> # ℹ abbreviated names: ¹​CUSTODIAN_ORG_DESCRIPTION,
#> #   ²​BUSINESS_CATEGORY_CLASS
#> # ℹ 39 more variables: BUSINESS_CATEGORY_DESCRIPTION <chr>,
#> #   OCCUPANT_TYPE_DESCRIPTION <chr>, SOURCE_DATA_ID <chr>,
#> #   SUPPLIED_SOURCE_ID_IND <chr>, AIRPORT_NAME <chr>,
#> #   DESCRIPTION <chr>, PHYSICAL_ADDRESS <chr>, …
# }
```
