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

try(
  ## Columns that can selected:
  feature_spec[feature_spec$sticky == TRUE,]
)
#> # A tibble: 9 × 5
#>   col_name             sticky remote_col_type local_col_type
#>   <chr>                <lgl>  <chr>           <chr>         
#> 1 id                   TRUE   xsd:string      character     
#> 2 CUSTODIAN_ORG_DESCR… TRUE   xsd:string      character     
#> 3 BUSINESS_CATEGORY_C… TRUE   xsd:string      character     
#> 4 BUSINESS_CATEGORY_D… TRUE   xsd:string      character     
#> 5 OCCUPANT_TYPE_DESCR… TRUE   xsd:string      character     
#> 6 SOURCE_DATA_ID       TRUE   xsd:string      character     
#> 7 SUPPLIED_SOURCE_ID_… TRUE   xsd:string      character     
#> 8 AIRPORT_NAME         TRUE   xsd:string      character     
#> 9 SEQUENCE_ID          TRUE   xsd:decimal     numeric       
#> # ℹ 1 more variable: column_comments <chr>

## Select columns
try(
  res <- bcdc_query_geodata("bc-airports") %>%
    select(DESCRIPTION, PHYSICAL_ADDRESS)
)

## Select "sticky" columns
try(
  res <- bcdc_query_geodata("bc-airports") %>%
    select(LOCALITY)
)
# }

```
