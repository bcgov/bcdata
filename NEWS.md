# bcdata (development version)

### User-facing changes

* For WFS queries constructed using `bcdc_query_geodata()`, function calls in `filter()` that need to be evaluated locally are no-longer auto-detected. They now need to be wrapped in `local()` to force local evaluation before the `CQL` query is constructed and sent to the WFS server. Please see `vignette("local-filter")` for more information. This aligns with recommended usage patterns in other `dbplyr` backends (#304, PR #305).

# bcdata 0.3.2

* Fixed a test that was failing when no internet was available
* Upgraded to `dbplyr` edition 2, bumped dependency to `2.0.0` (#300)

# bcdata 0.3.1

* Added `bcdc_get_citation` to generate bibliographic entries (via `utils::bibentry`) for individuals records. #273
* Results from `bcdc_search()` (objects of class `"bcdc_recordlist"`) now print 50 records by default, instead of 10. In addition, there is a new `[` method for `"bcdc_recordlist"` objects, allowing you to subset these lists and still have a nice printout (#288).
* Ensure that `bcdc_get_data()` fails informatively when a given resource doesn't exist in a record (#290)
* Ensure compatibility with upcoming `dbplyr 2.2.0` (#297, 82b9defa376ab)

# bcdata 0.3.0

* The [BC Data Catalogue and its API have been updated](https://www2.gov.bc.ca/gov/content?id=8A553CABCCDD434D8614D1CA92B03400), requiring changes to the `bcdata` package, most of which are internal only (#283). These should be mostly invisible to the user, except for the removal of the `type` search facet in `bcdc_search()` and `bcdc_search_facets()`. If you use an API key (authorized catalogue editors only), you will need to login to the new catalogue and get your updated key and set the value your `BCDC_KEY` environment variable to the new key.

### IMPROVEMENTS
* Add `names` method for `bcdc.promise` objects. You can now call `names` on an object produced by `bcdc_query_geodata`. This is handy when trying to figure out exact column spelling etc. #278

### BUG FIXES
* Fix bug where sticky column were incorrectly identified in `bcdc_describe_feature` (#279)

# bcdata 0.2.4

* Code in `.onLoad()` that sent a request to the wfs getCapabilities endpoint could cause the package to fail to load. This was moved into an internal function `bcdc_get_capabilities()` that makes the request the first time it's required, and stores the result for the remainder of the session (#271)
* testthat is now used conditionally to only run tests if the testthat package is installed.

# bcdata 0.2.3

### IMPROVEMENTS
- Setting the `bcdata.single_download_limit` limit dynamically from the getCapabilities endpoint. #256
- `bcdc_describe_feature` now joins an object description column to the returned object to provide more information about a field directly in R. #241, #259
- Better documentation and information surrounding the `bcdata.max_geom_pred_size` option. #243, #258 
- Add new function `bcdc_check_geom_size` so users can check prior to submitting a WFS request with `filter` to see 
if the request will require a bounding box conversion. #243, #258
- Better documentation and messaging about when and why paginated requests are required by `bcdc_query_geodata()`. #240, #264
- Better documentation and print method for what records are suitable for use with `bcdc_query_geodata()`. #265, #267

# bcdata 0.2.2
### IMPROVEMENTS
* Added `bcdc_list_groups` and `bcdc_list_group_records` to provide the ability to query on the group endpoint of the catalogue API. #234
* Added new option `bcdata.single_download_limit` to enable setting the maximum number of records an object can be before forcing a paginated download (#252)

### BUG FIXES
* Fixed bug in `collect.bcdc_promise` where the wrong parameter name in `crul::Paginator$new()` resulted in an error in paginated wfs requests (#250, thanks @meztez)
* Fixed a bug where the name of `bcdata.chunk_limit` option had a typo, so that it was not actually used properly (#252)

# bcdata 0.2.1

### BUG FIXES
* Remove link for pipe documentation for simplicity.
* Fixed bug where using many `as.` functions (e.g., `as.Date()`, `as.character()`, `as.numeric()`) in a filter statement would fail. (#218, #219)

### MAINTENANCE
* Updated internal SQL translation to use `DBI` S4 generics (`DBI::dbQuoteIdentifier()` is now used instead of 
  `dbplyr::sql_escape_ident()` and `DBI::dbQuoteString()` instead of `dbplyr::sql_escape_string()`), to comply 
  with upcoming `dbplyr` 2.0 release (#225, #225; https://github.com/tidyverse/dbplyr/issues/385)
* Wrapped all examples that call web resources in `try()` to avoid spurious check failures (#229).

# bcdata 0.2.0

### BREAKING CHANGES
* Rename `selectable` column from `bcdc_describe_feature` to `sticky` and modify corresponding docs and tests (#180).

### IMPROVEMENTS
* Add explore-silviculture-data-using-bcdata vignette/article. h/t @hgriesbauer 
* Add `head` and `tail` methods for `bcdc.promise` objects. Thanks to @hgriesbauer for the suggestion! (#182, #186)
* Provide `as_tibble` as an alias for `collect` in line with `dbplyr` behaviour (#166)
* Geometry predicates can now take a `bbox` object as well as an `sf*` object (#176)
* When reading in excel files, `bcdc_get_data` now outputs a messages indicating the presence and names of any sheets (#190)
* `bcdc_get_data()` & `bcdc_query_geodata()` will now work with full B.C. data catalogue url including resource (#125, #196)
* `bcdc_sf` objects now have an `time_downloaded` attribute
* Authorized B.C. Data Catalogue editors can now authenticate with the catalogue by setting 
a `BCDC_KEY` environment variable with their catalogue API token (https://github.com/bcgov/bcdata#bcdc-authentication; #208).

### BUG FIXES
* Fix `select`, `filter` and `mutate` roxygen so that bcdata specific documentation to these methods is available
* Add tests for attributes

# bcdata 0.1.2

### IMPROVEMENTS
* Add `bcdc_tidy_resources` for retrieving a data frame containing the metadata for all resources from a single B.C. Data Catalogue record (PR#149, #147)
* Add a more decorative record print method  (#73)
* More reliable detection of layer name for a wfs call in `bcdc_query_geodata()` (#129, #138, #139)
* Add `mutate` method for bcdc_promise that only fails and suggest an alternative approach. (PR#134)
* Add back in querying vignette
* Using `tidyselect` so that `select.bcdc_promise` behaviour is typical of `dplyr::select` ($140, #138)
* Using GitHub actions for CI. 

### MINOR BREAKING CHANGES
* Remove `BEYOND()` and `RELATE()` geometry predicates as they are currently not fully supported by geoserver
                                                        
### BUG FIXES
* Now precompiling vignettes so that queries are submitted locally and no actually requests are made from CRAN (#151)
* Fix `NOTE: Namespace in Imports field not imported from: ‘methods’` error on CRAN (#145)
* Fixed a bug where functions nested inside geometry predicates were not evaluated (#146, #154)
* Fixed a bug where `DWITHIN` wasn't working because `units` needed to be unquoted (#154)
* Fixed a bug where `BBOX()` used in a `filter()` statement combined with `bcdc_query_geodata()` did not work (#135, #137, #131)
* Fixed a bug where layer names with a number in them would not work in `bcdc_query_geodata()` (#126, #127)


# bcdata 0.1.1

* Expand and standardize checking w[ms]f features to make package more resistant to slight warehouse API changes. 
* Data retrieval functions now work with BCGW name (#106)
* Add CITATION file (#104)
* Increased test coverage (#112)
* Skipping all tests on CRAN that require a web connection
* Better and more informative error message when experiencing http failures occur (#121)
* Added print methods for `show_query`
* Change examples to donttest
* Added verbose argument to `bcdc_get_record` to enable suppressing console writing

# bcdata 0.1.0

* Initial Release
