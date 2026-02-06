# Describe the attributes of a Web Feature Service

Describe the attributes of column of a record accessed through the Web
Feature Service. This can be a useful tool to examine a layer before
issuing a query with `bcdc_query_geodata`.

## Usage

``` r
bcdc_describe_feature(record)
```

## Arguments

- record:

  either a `bcdc_record` object (from the result of
  [`bcdc_get_record()`](https://bcgov.github.io/bcdata/reference/bcdc_get_record.md)),
  a character string denoting the name or ID of a resource (or the URL)
  or a BC Geographic Warehouse (BCGW) name.

  It is advised to use the permanent ID for a record or the BCGW name
  rather than the human-readable name to guard against future name
  changes of the record. If you use the human-readable name a warning
  will be issued once per session. You can silence these warnings
  altogether by setting an option:
  `options("silence_named_get_data_warning" = TRUE)` - which you can set
  in your .Rprofile file so the option persists across sessions.

## Value

`bcdc_describe_feature` returns a tibble describing the attributes of a
B.C. Data Catalogue record. The tibble returns the following columns:

- col_name: attributes of the feature

- sticky: whether a column can be separated from the record in a Web
  Feature Service call via the
  [`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
  method

- remote_col_type: class of what is return by the web feature service

- local_col_type: the column class in R

- column_comments: additional metadata specific to that column

## Examples

``` r
# \donttest{
try(
  bcdc_describe_feature("bc-airports")
)
#> # A tibble: 42 × 5
#>    col_name            sticky remote_col_type local_col_type
#>    <chr>               <lgl>  <chr>           <chr>         
#>  1 id                  TRUE   xsd:string      character     
#>  2 CUSTODIAN_ORG_DESC… TRUE   xsd:string      character     
#>  3 BUSINESS_CATEGORY_… TRUE   xsd:string      character     
#>  4 BUSINESS_CATEGORY_… TRUE   xsd:string      character     
#>  5 OCCUPANT_TYPE_DESC… TRUE   xsd:string      character     
#>  6 SOURCE_DATA_ID      TRUE   xsd:string      character     
#>  7 SUPPLIED_SOURCE_ID… TRUE   xsd:string      character     
#>  8 AIRPORT_NAME        TRUE   xsd:string      character     
#>  9 DESCRIPTION         FALSE  xsd:string      character     
#> 10 PHYSICAL_ADDRESS    FALSE  xsd:string      character     
#> # ℹ 32 more rows
#> # ℹ 1 more variable: column_comments <chr>

try(
  bcdc_describe_feature("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
)
#> # A tibble: 42 × 5
#>    col_name            sticky remote_col_type local_col_type
#>    <chr>               <lgl>  <chr>           <chr>         
#>  1 id                  TRUE   xsd:string      character     
#>  2 CUSTODIAN_ORG_DESC… TRUE   xsd:string      character     
#>  3 BUSINESS_CATEGORY_… TRUE   xsd:string      character     
#>  4 BUSINESS_CATEGORY_… TRUE   xsd:string      character     
#>  5 OCCUPANT_TYPE_DESC… TRUE   xsd:string      character     
#>  6 SOURCE_DATA_ID      TRUE   xsd:string      character     
#>  7 SUPPLIED_SOURCE_ID… TRUE   xsd:string      character     
#>  8 AIRPORT_NAME        TRUE   xsd:string      character     
#>  9 DESCRIPTION         FALSE  xsd:string      character     
#> 10 PHYSICAL_ADDRESS    FALSE  xsd:string      character     
#> # ℹ 32 more rows
#> # ℹ 1 more variable: column_comments <chr>
# }
```
