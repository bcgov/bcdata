# Get preview map from the B.C. Web Map Service

Note this does not return the actual map features, rather opens an image
preview of the layer in a [Leaflet](https://rstudio.github.io/leaflet/)
map window

## Usage

``` r
bcdc_preview(record)
```

## Arguments

- record:

  either a `bcdc_record` object (from the result of
  [`bcdc_get_record()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_get_record.md)),
  a character string denoting the name or ID of a resource (or the URL)
  or a BC Geographic Warehouse (BCGW) name.

  It is advised to use the permanent ID for a record or the BCGW name
  rather than the human-readable name to guard against future name
  changes of the record. If you use the human-readable name a warning
  will be issued once per session. You can silence these warnings
  altogether by setting an option:
  `options("silence_named_get_data_warning" = TRUE)` - which you can set
  in your .Rprofile file so the option persists across sessions.

## Examples

``` r
# \donttest{
try(
  bcdc_preview("regional-districts-legally-defined-administrative-areas-of-bc")
)

{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["CartoDB.Positron",null,null,{"errorTileUrl":"","noWrap":true,"detectRetina":false}]},{"method":"addWMSTiles","args":["https://openmaps.gov.bc.ca/geo/pub/wms",null,null,{"styles":"","format":"image/png","transparent":true,"version":"1.1.1","layers":"pub:WHSE_LEGAL_ADMIN_BOUNDARIES.ABMS_REGIONAL_DISTRICTS_SP"}]},{"method":"addControl","args":["<img src=\"https://openmaps.gov.bc.ca/geo/pub/wms?request=GetLegendGraphic&\nformat=image%2Fpng&\nwidth=20&\nheight=20&\nlayer=pub%3AWHSE_LEGAL_ADMIN_BOUNDARIES.ABMS_REGIONAL_DISTRICTS_SP\">","bottomright",null,"info legend"]}],"setView":[[54.5,-126.5],5,[]]},"evals":[],"jsHooks":[]}
try(
  bcdc_preview("water-reservations-points")
)

{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["CartoDB.Positron",null,null,{"errorTileUrl":"","noWrap":true,"detectRetina":false}]},{"method":"addWMSTiles","args":["https://openmaps.gov.bc.ca/geo/pub/wms",null,null,{"styles":"","format":"image/png","transparent":true,"version":"1.1.1","layers":"pub:WHSE_WATER_MANAGEMENT.WLS_WATER_RESERVATION_SV"}]},{"method":"addControl","args":["<img src=\"https://openmaps.gov.bc.ca/geo/pub/wms?request=GetLegendGraphic&\nformat=image%2Fpng&\nwidth=20&\nheight=20&\nlayer=pub%3AWHSE_WATER_MANAGEMENT.WLS_WATER_RESERVATION_SV\">","bottomright",null,"info legend"]}],"setView":[[54.5,-126.5],5,[]]},"evals":[],"jsHooks":[]}
# Using BCGW name
try(
  bcdc_preview("WHSE_LEGAL_ADMIN_BOUNDARIES.ABMS_REGIONAL_DISTRICTS_SP")
)

{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["CartoDB.Positron",null,null,{"errorTileUrl":"","noWrap":true,"detectRetina":false}]},{"method":"addWMSTiles","args":["https://openmaps.gov.bc.ca/geo/pub/wms",null,null,{"styles":"","format":"image/png","transparent":true,"version":"1.1.1","layers":"pub:WHSE_LEGAL_ADMIN_BOUNDARIES.ABMS_REGIONAL_DISTRICTS_SP"}]},{"method":"addControl","args":["<img src=\"https://openmaps.gov.bc.ca/geo/pub/wms?request=GetLegendGraphic&\nformat=image%2Fpng&\nwidth=20&\nheight=20&\nlayer=pub%3AWHSE_LEGAL_ADMIN_BOUNDARIES.ABMS_REGIONAL_DISTRICTS_SP\">","bottomright",null,"info legend"]}],"setView":[[54.5,-126.5],5,[]]},"evals":[],"jsHooks":[]}# }
```
