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
#> Warning: It is advised to use the permanent id ('76b1b7a3-2112-4444-857a-afccf7b20da8') rather than the name of the record ('bc-airports') to guard against future name changes.
# }
```
