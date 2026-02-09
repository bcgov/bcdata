# Check spatial objects for WFS spatial operations

Check a spatial object to see if it exceeds the current set value of
'bcdata.max_geom_pred_size' option, which controls how the object is
treated when used inside a spatial predicate function in
[`filter.bcdc_promise()`](https://bcgov.github.io/bcdata/dev/reference/filter.md).
If the object does exceed the size threshold a bounding box is drawn
around it and all features within the box will be returned. Further
options include:

- Try adjusting the value of the 'bcdata.max_geom_pred_size' option

- Simplify the spatial object to reduce its size

- Further processing on the returned object

## Usage

``` r
bcdc_check_geom_size(x)
```

## Arguments

- x:

  object of class sf, sfc or sfg

## Value

invisibly return logical indicating whether the check pass. If the
return value is TRUE, the object will not need a bounding box drawn. If
the return value is FALSE, the check will fails and a bounding box will
be drawn.

## Details

See the [Querying Spatial Data with
bcdata](https://bcgov.github.io/bcdata/articles/efficiently-query-spatial-data-in-the-bc-data-catalogue.html)
for more details.

## Examples

``` r
# \donttest{
try({
  airports <- bcdc_query_geodata("bc-airports") %>% collect()
  bcdc_check_geom_size(airports)
})
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10003 ms: Timeout was reached
# }
```
