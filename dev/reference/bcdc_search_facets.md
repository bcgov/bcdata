# Get the valid values for a facet (that you can use in [`bcdc_search()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_search.md))

Get the valid values for a facet (that you can use in
[`bcdc_search()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_search.md))

## Usage

``` r
bcdc_search_facets(
  facet = c("license_id", "download_audience", "res_format", "publish_state",
    "organization", "groups")
)
```

## Arguments

- facet:

  the facet(s) for which to retrieve valid values. Can be one or more
  of:
  `"license_id", "download_audience", "res_format", "publish_state", "organization", "groups"`

## Value

A data frame of values for the selected facet

## Examples

``` r
# \donttest{
try(
  bcdc_search_facets("download_audience")
)
#>               facet                          name
#> 1 download_audience                        Public
#> 2 download_audience              Not downloadable
#> 3 download_audience                   Named users
#> 4 download_audience                            NA
#> 5 download_audience Government and Business BCeID
#> 6 download_audience                    Government
#>                    display_name count
#> 1                        Public  2391
#> 2              Not downloadable   229
#> 3                   Named users    56
#> 4                            NA   174
#> 5 Government and Business BCeID     8
#> 6                    Government   483

try(
  bcdc_search_facets("res_format")
)
#>         facet         name display_name count
#> 1  res_format          zip          zip    35
#> 2  res_format          xml          xml    20
#> 3  res_format         xlsx         xlsx   698
#> 4  res_format          xls          xls   303
#> 5  res_format         wmts         wmts     1
#> 6  res_format          wms          wms   878
#> 7  res_format          txt          txt    30
#> 8  res_format          shp          shp    68
#> 9  res_format          pdf          pdf   194
#> 10 res_format        other        other   337
#> 11 res_format   oracle_sde   oracle_sde   463
#> 12 res_format openapi-json openapi-json    12
#> 13 res_format     multiple     multiple  1110
#> 14 res_format          kmz          kmz    31
#> 15 res_format          kml          kml   876
#> 16 res_format         json         json    12
#> 17 res_format         html         html   107
#> 18 res_format         gpkg         gpkg    22
#> 19 res_format      geojson      geojson    18
#> 20 res_format         fgdb         fgdb    96
#> 21 res_format          csv          csv   574
#> 22 res_format  arcgis_rest  arcgis_rest   169
# }
```
