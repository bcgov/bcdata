# bcdata (development version)

# bcdata 0.1.1.9999

* More reliable detection of layer name for a wfs call in `bcdc_query_geodata()` (#129, #138, #139)
* Fixed a bug where `BBOX()` used in a `filter()` statement combined with `bcdc_query_geodata()` did not work (#135, #137)
* Add `mutate` method for bcdc_promise that only fails and suggest an alternative approach. (PR#134)
* Fixed a bug where layer names with a number in them would not work in `bcdc_query_geodata()` (#126, #127)
* Add back in querying vignette
* Using `tidyselect` so that `select.bcdc_promise` behaviour is typical of `dplyr::select`

# bcdata 0.1.1

* Expand and standardize checking w[ms]f features to make package more resistant to slight warehouse API changes. 
* Data retrieval functions now work with BCGW name (#106)
* Add CITATION file (#104)
* Increased test coverage (#112)
* Skipping all tests on CRAN that require a web connection
* Better and more informative error message when experiencing http failures occur (#121)
* Added print methods for `show_query`
* Change examples to donttest
* Added verbose argument to `bcdc_get_record` to enable supressing console writing

# bcdata 0.1.0

* Initial Release
