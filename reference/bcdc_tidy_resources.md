# Provide a data frame containing the metadata for all resources from a single B.C. Data Catalogue record

Returns a rectangular data frame of all resources contained within a
record. This is particularly useful if you are trying to construct a
vector of multiple resources in a record. The data frame also provides
useful information on the formats, availability and types of data
available.

## Usage

``` r
bcdc_tidy_resources(record)
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

A data frame containing the metadata for all the resources for a record

## Examples

``` r
# \donttest{
try(
  airports <- bcdc_get_record("bc-airports")
)

try(
  bcdc_tidy_resources(airports)
)
#> # A tibble: 4 × 9
#>   name          url   id    format ext   package_id location
#>   <chr>         <chr> <chr> <chr>  <chr> <chr>      <chr>   
#> 1 BC Geographi… ""    604c… multi… ""    76b1b7a3-… bcgeogr…
#> 2 BC_Airports_… "htt… fccc… xlsx   "xls… 76b1b7a3-… catalog…
#> 3 WMS getCapab… "htt… 4d03… wms    ""    76b1b7a3-… bcgeogr…
#> 4 Download KML… "htt… 5b9f… kml    "kml" 76b1b7a3-… bcgeogr…
#> # ℹ 2 more variables: wfs_available <lgl>,
#> #   bcdata_available <lgl>
# }
```
