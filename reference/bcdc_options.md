# Retrieve options used in bcdata, their value if set and the default value.

This function retrieves bcdata specific options that can be set. These
options can be set using
`option({name of the option} = {value of the option})`. The default
options are purposefully set conservatively to hopefully ensure
successful requests. Resetting these options may result in failed calls
to the data catalogue. Options in R are reset every time R is
re-started. See examples for additional ways to restore your initial
state.

## Usage

``` r
bcdc_options()
```

## Details

`bcdata.max_geom_pred_size` is the maximum size in bytes of an object
used for a geometric operation. Objects that are bigger than this value
will have a bounding box drawn and apply the geometric operation on that
simpler polygon. The
[bcdc_check_geom_size](https://bcgov.github.io/bcdata/reference/bcdc_check_geom_size.md)
function can be used to assess whether a given spatial object exceeds
the value of this option. Users can iteratively try to increase the
maximum geometric predicate size and see if the bcdata catalogue accepts
the request.

`bcdata.chunk_limit` is an option useful when dealing with very large
data sets. When requesting large objects from the catalogue, the request
is broken up into smaller chunks which are then recombined after they've
been downloaded. This is called "pagination". bcdata does this all for
you, however by using this option you can set the size of the chunk
requested. On slower connections, or when having problems, it may help
to lower the chunk limit.

`bcdata.max_package_search_limit` is an option for setting the maximum
number of datasets returned when querying by organization with the
package_search API endpoint. The default limit (1000) is purposely set
high to return all datasets for a given organization.

`bcdata.max_package_search_facet_limit` is an option for setting the
maximum number of values returned when querying facet fields with the
package_search API endpoint. The default limit (1000) is purposely set
high to return all values for each facet field ("license_id",
"download_audience", "res_format", "publish_state", "organization",
"groups").

`bcdata.max_group_package_show_limit` is an option for setting the
maximum number of datasets returned when querying by group with the
group_package_show API endpoint. The default limit (1000) is purposely
set high to return all datasets for a given group.

`bcdata.single_download_limit` *Deprecated*. This is the maximum number
of records an object can be before forcing a paginated download; it is
set by querying the server capabilities. This option is deprecated and
will be removed in a future release. Use `bcdata.chunk_limit` to set a
lower value pagination value.

## Examples

``` r
# \donttest{
## Save initial conditions
try(
  original_options <- options()
)

## See initial options
try(
  bcdc_options()
)
#> # A tibble: 6 × 3
#>   option                                value default
#>   <chr>                                 <dbl>   <dbl>
#> 1 bcdata.max_geom_pred_size                NA  500000
#> 2 bcdata.chunk_limit                       NA   10000
#> 3 bcdata.single_download_limit          10000   10000
#> 4 bcdata.max_package_search_limit          NA    1000
#> 5 bcdata.max_package_search_facet_limit    NA    1000
#> 6 bcdata.max_group_package_show_limit      NA    1000

try(
  options(bcdata.max_geom_pred_size = 1E6)
)

## See updated options
try(
  bcdc_options()
)
#> # A tibble: 6 × 3
#>   option                                  value default
#>   <chr>                                   <dbl>   <dbl>
#> 1 bcdata.max_geom_pred_size             1000000  500000
#> 2 bcdata.chunk_limit                         NA   10000
#> 3 bcdata.single_download_limit            10000   10000
#> 4 bcdata.max_package_search_limit            NA    1000
#> 5 bcdata.max_package_search_facet_limit      NA    1000
#> 6 bcdata.max_group_package_show_limit        NA    1000

## Reset initial conditions
try(
  options(original_options)
)
# }
```
