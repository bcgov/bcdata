# bcdata (development version)

# bcdata 0.1.1.9999
* Add `mutate` method for bcdc_promise that only fails and suggest an alternative approach. (PR#134)
* Add back in querying vignette

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
