# Changelog

## bcdata 0.5.2

CRAN release: 2026-02-07

- Removed dependency on `leaflet.extras`, using
  [`leaflet::addControl()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
  instead of `leaflet.extras::addWMSLegend()` for WMS legend display
  ([\#364](https://github.com/bcgov/bcdata/issues/364)).

## bcdata 0.5.1

CRAN release: 2025-03-26

- Fix bugs where
  [`bcdc_search_facets()`](https://bcgov.github.io/bcdata/reference/bcdc_search_facets.md),
  [`bcdc_list_group_records()`](https://bcgov.github.io/bcdata/reference/bcdc_list_group_records.md)
  and
  [`bcdc_list_organization_records()`](https://bcgov.github.io/bcdata/reference/bcdc_list_organization_records.md)
  were not returning all records after the upgrade to CKAN 2.9
  ([\#353](https://github.com/bcgov/bcdata/issues/353)). Includes adding
  tests and bcdata-specific options for these queries, see
  [`bcdc_options()`](https://bcgov.github.io/bcdata/reference/bcdc_options.md).
- Added examples of partial query using `%like%` and `%in%` in
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md)
  ([\#356](https://github.com/bcgov/bcdata/issues/356), thanks
  [@bevingtona](https://github.com/bevingtona)).

## bcdata 0.5.0

CRAN release: 2024-12-12

- Make functions more robust to non-functioning WMS/WFS GetCapabilities
  requests ([\#339](https://github.com/bcgov/bcdata/issues/339),
  [\#341](https://github.com/bcgov/bcdata/issues/341)).
- dbplyr 2.5.0 has made the requirement for using `!!` or
  [`local()`](https://rdrr.io/r/base/eval.html) for local functions more
  restrictive; updated tests and examples
  ([\#341](https://github.com/bcgov/bcdata/issues/341)).
- Deprecate the `bcdata.single_download_limit` option, as it was mostly
  redundant with `bcdata.chunk_limit`, and should always be set by the
  server. Please set the page size limit for paginated requests via the
  `bcdata.chunk_limit` option
  ([\#332](https://github.com/bcgov/bcdata/issues/332)).
- Updated internals to adapt to changes in B.C. Data Catalogue
  ([\#342](https://github.com/bcgov/bcdata/issues/342),
  [\#343](https://github.com/bcgov/bcdata/issues/343)).

## bcdata 0.4.1

CRAN release: 2023-03-18

- Add
  [`jsonlite::read_json()`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html)
  as a file read method, so users can now download & read `json`
  resources in B.C. Data Catalogue records
- Change the `download_audience` default from `Public` to `NULL` in
  [`bcdc_search()`](https://bcgov.github.io/bcdata/reference/bcdc_search.md)
  ([\#315](https://github.com/bcgov/bcdata/issues/315))
- Fix bug where some/all facet values in
  [`bcdc_search()`](https://bcgov.github.io/bcdata/reference/bcdc_search.md)
  need to be quoted to generate a valid API query
  ([\#315](https://github.com/bcgov/bcdata/issues/315))
- Add new functions `bcdc_list_organizations` and
  `bcdc_list_organization_records` as helper functions for finding
  records [\#322](https://github.com/bcgov/bcdata/issues/322)

## bcdata 0.4.0

CRAN release: 2023-01-05

#### User-facing changes

- For WFS queries constructed using
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md),
  function calls in
  [`filter()`](https://bcgov.github.io/bcdata/reference/filter.md) that
  need to be evaluated locally are no-longer auto-detected. They now
  need to be wrapped in [`local()`](https://rdrr.io/r/base/eval.html) to
  force local evaluation before the `CQL` query is constructed and sent
  to the WFS server. Please see
  [`vignette("local-filter")`](https://bcgov.github.io/bcdata/articles/local-filter.md)
  for more information. This aligns with recommended usage patterns in
  other `dbplyr` backends
  ([\#304](https://github.com/bcgov/bcdata/issues/304), PR
  [\#305](https://github.com/bcgov/bcdata/issues/305)).

## bcdata 0.3.2

CRAN release: 2022-07-06

- Fixed a test that was failing when no internet was available
- Upgraded to `dbplyr` edition 2, bumped dependency to `2.0.0`
  ([\#300](https://github.com/bcgov/bcdata/issues/300))

## bcdata 0.3.1

CRAN release: 2022-05-24

- Added `bcdc_get_citation` to generate bibliographic entries (via
  [`utils::bibentry`](https://rdrr.io/r/utils/bibentry.html)) for
  individuals records.
  [\#273](https://github.com/bcgov/bcdata/issues/273)
- Results from
  [`bcdc_search()`](https://bcgov.github.io/bcdata/reference/bcdc_search.md)
  (objects of class `"bcdc_recordlist"`) now print 50 records by
  default, instead of 10. In addition, there is a new `[` method for
  `"bcdc_recordlist"` objects, allowing you to subset these lists and
  still have a nice printout
  ([\#288](https://github.com/bcgov/bcdata/issues/288)).
- Ensure that
  [`bcdc_get_data()`](https://bcgov.github.io/bcdata/reference/bcdc_get_data.md)
  fails informatively when a given resource doesn’t exist in a record
  ([\#290](https://github.com/bcgov/bcdata/issues/290))
- Ensure compatibility with upcoming `dbplyr 2.2.0`
  ([\#297](https://github.com/bcgov/bcdata/issues/297), 82b9defa376ab)

## bcdata 0.3.0

CRAN release: 2021-10-28

- The BC Data Catalogue and its API have been updated, requiring changes
  to the `bcdata` package, most of which are internal only
  ([\#283](https://github.com/bcgov/bcdata/issues/283)). These should be
  mostly invisible to the user, except for the removal of the `type`
  search facet in
  [`bcdc_search()`](https://bcgov.github.io/bcdata/reference/bcdc_search.md)
  and
  [`bcdc_search_facets()`](https://bcgov.github.io/bcdata/reference/bcdc_search_facets.md).
  If you use an API key (authorized catalogue editors only), you will
  need to login to the new catalogue and get your updated key and set
  the value your `BCDC_KEY` environment variable to the new key.

#### IMPROVEMENTS

- Add `names` method for `bcdc.promise` objects. You can now call
  `names` on an object produced by `bcdc_query_geodata`. This is handy
  when trying to figure out exact column spelling etc.
  [\#278](https://github.com/bcgov/bcdata/issues/278)

#### BUG FIXES

- Fix bug where sticky column were incorrectly identified in
  `bcdc_describe_feature`
  ([\#279](https://github.com/bcgov/bcdata/issues/279))

## bcdata 0.2.4

CRAN release: 2021-05-04

- Code in `.onLoad()` that sent a request to the wfs getCapabilities
  endpoint could cause the package to fail to load. This was moved into
  an internal function `bcdc_get_capabilities()` that makes the request
  the first time it’s required, and stores the result for the remainder
  of the session ([\#271](https://github.com/bcgov/bcdata/issues/271))
- testthat is now used conditionally to only run tests if the testthat
  package is installed.

## bcdata 0.2.3

CRAN release: 2021-04-24

#### IMPROVEMENTS

- Setting the `bcdata.single_download_limit` limit dynamically from the
  getCapabilities endpoint.
  [\#256](https://github.com/bcgov/bcdata/issues/256)
- `bcdc_describe_feature` now joins an object description column to the
  returned object to provide more information about a field directly
  in R. [\#241](https://github.com/bcgov/bcdata/issues/241),
  [\#259](https://github.com/bcgov/bcdata/issues/259)
- Better documentation and information surrounding the
  `bcdata.max_geom_pred_size` option.
  [\#243](https://github.com/bcgov/bcdata/issues/243),
  [\#258](https://github.com/bcgov/bcdata/issues/258)
- Add new function `bcdc_check_geom_size` so users can check prior to
  submitting a WFS request with `filter` to see if the request will
  require a bounding box conversion.
  [\#243](https://github.com/bcgov/bcdata/issues/243),
  [\#258](https://github.com/bcgov/bcdata/issues/258)
- Better documentation and messaging about when and why paginated
  requests are required by
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md).
  [\#240](https://github.com/bcgov/bcdata/issues/240),
  [\#264](https://github.com/bcgov/bcdata/issues/264)
- Better documentation and print method for what records are suitable
  for use with
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md).
  [\#265](https://github.com/bcgov/bcdata/issues/265),
  [\#267](https://github.com/bcgov/bcdata/issues/267)

## bcdata 0.2.2

CRAN release: 2021-03-12

#### IMPROVEMENTS

- Added `bcdc_list_groups` and `bcdc_list_group_records` to provide the
  ability to query on the group endpoint of the catalogue API.
  [\#234](https://github.com/bcgov/bcdata/issues/234)
- Added new option `bcdata.single_download_limit` to enable setting the
  maximum number of records an object can be before forcing a paginated
  download ([\#252](https://github.com/bcgov/bcdata/issues/252))

#### BUG FIXES

- Fixed bug in `collect.bcdc_promise` where the wrong parameter name in
  `crul::Paginator$new()` resulted in an error in paginated wfs requests
  ([\#250](https://github.com/bcgov/bcdata/issues/250), thanks
  [@meztez](https://github.com/meztez))
- Fixed a bug where the name of `bcdata.chunk_limit` option had a typo,
  so that it was not actually used properly
  ([\#252](https://github.com/bcgov/bcdata/issues/252))

## bcdata 0.2.1

CRAN release: 2020-10-25

#### BUG FIXES

- Remove link for pipe documentation for simplicity.
- Fixed bug where using many `as.` functions (e.g.,
  [`as.Date()`](https://rdrr.io/r/base/as.Date.html),
  [`as.character()`](https://rdrr.io/r/base/character.html),
  [`as.numeric()`](https://rdrr.io/r/base/numeric.html)) in a filter
  statement would fail.
  ([\#218](https://github.com/bcgov/bcdata/issues/218),
  [\#219](https://github.com/bcgov/bcdata/issues/219))

#### MAINTENANCE

- Updated internal SQL translation to use `DBI` S4 generics
  ([`DBI::dbQuoteIdentifier()`](https://dbi.r-dbi.org/reference/dbQuoteIdentifier.html)
  is now used instead of `dbplyr::sql_escape_ident()` and
  [`DBI::dbQuoteString()`](https://dbi.r-dbi.org/reference/dbQuoteString.html)
  instead of `dbplyr::sql_escape_string()`), to comply with upcoming
  `dbplyr` 2.0 release
  ([\#225](https://github.com/bcgov/bcdata/issues/225),
  [\#225](https://github.com/bcgov/bcdata/issues/225);
  <https://github.com/tidyverse/dbplyr/issues/385>)
- Wrapped all examples that call web resources in
  [`try()`](https://rdrr.io/r/base/try.html) to avoid spurious check
  failures ([\#229](https://github.com/bcgov/bcdata/issues/229)).

## bcdata 0.2.0

CRAN release: 2020-06-25

#### BREAKING CHANGES

- Rename `selectable` column from `bcdc_describe_feature` to `sticky`
  and modify corresponding docs and tests
  ([\#180](https://github.com/bcgov/bcdata/issues/180)).

#### IMPROVEMENTS

- Add explore-silviculture-data-using-bcdata vignette/article. h/t
  [@hgriesbauer](https://github.com/hgriesbauer)
- Add `head` and `tail` methods for `bcdc.promise` objects. Thanks to
  [@hgriesbauer](https://github.com/hgriesbauer) for the suggestion!
  ([\#182](https://github.com/bcgov/bcdata/issues/182),
  [\#186](https://github.com/bcgov/bcdata/issues/186))
- Provide `as_tibble` as an alias for `collect` in line with `dbplyr`
  behaviour ([\#166](https://github.com/bcgov/bcdata/issues/166))
- Geometry predicates can now take a `bbox` object as well as an `sf*`
  object ([\#176](https://github.com/bcgov/bcdata/issues/176))
- When reading in excel files, `bcdc_get_data` now outputs a messages
  indicating the presence and names of any sheets
  ([\#190](https://github.com/bcgov/bcdata/issues/190))
- [`bcdc_get_data()`](https://bcgov.github.io/bcdata/reference/bcdc_get_data.md)
  &
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md)
  will now work with full B.C. data catalogue url including resource
  ([\#125](https://github.com/bcgov/bcdata/issues/125),
  [\#196](https://github.com/bcgov/bcdata/issues/196))
- `bcdc_sf` objects now have an `time_downloaded` attribute
- Authorized B.C. Data Catalogue editors can now authenticate with the
  catalogue by setting a `BCDC_KEY` environment variable with their
  catalogue API token
  (<https://github.com/bcgov/bcdata#bcdc-authentication>;
  [\#208](https://github.com/bcgov/bcdata/issues/208)).

#### BUG FIXES

- Fix `select`, `filter` and `mutate` roxygen so that bcdata specific
  documentation to these methods is available
- Add tests for attributes

## bcdata 0.1.2

CRAN release: 2019-12-17

#### IMPROVEMENTS

- Add `bcdc_tidy_resources` for retrieving a data frame containing the
  metadata for all resources from a single B.C. Data Catalogue record
  (PR#149, [\#147](https://github.com/bcgov/bcdata/issues/147))
- Add a more decorative record print method
  ([\#73](https://github.com/bcgov/bcdata/issues/73))
- More reliable detection of layer name for a wfs call in
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md)
  ([\#129](https://github.com/bcgov/bcdata/issues/129),
  [\#138](https://github.com/bcgov/bcdata/issues/138),
  [\#139](https://github.com/bcgov/bcdata/issues/139))
- Add `mutate` method for bcdc_promise that only fails and suggest an
  alternative approach. (PR#134)
- Add back in querying vignette
- Using `tidyselect` so that `select.bcdc_promise` behaviour is typical
  of
  [`dplyr::select`](https://dplyr.tidyverse.org/reference/select.html)
  (\$140, [\#138](https://github.com/bcgov/bcdata/issues/138))
- Using GitHub actions for CI.

#### MINOR BREAKING CHANGES

- Remove `BEYOND()` and `RELATE()` geometry predicates as they are
  currently not fully supported by geoserver

#### BUG FIXES

- Now precompiling vignettes so that queries are submitted locally and
  no actually requests are made from CRAN
  ([\#151](https://github.com/bcgov/bcdata/issues/151))
- Fix `NOTE: Namespace in Imports field not imported from: ‘methods’`
  error on CRAN ([\#145](https://github.com/bcgov/bcdata/issues/145))
- Fixed a bug where functions nested inside geometry predicates were not
  evaluated ([\#146](https://github.com/bcgov/bcdata/issues/146),
  [\#154](https://github.com/bcgov/bcdata/issues/154))
- Fixed a bug where `DWITHIN` wasn’t working because `units` needed to
  be unquoted ([\#154](https://github.com/bcgov/bcdata/issues/154))
- Fixed a bug where
  [`BBOX()`](https://bcgov.github.io/bcdata/reference/cql_geom_predicates.md)
  used in a
  [`filter()`](https://bcgov.github.io/bcdata/reference/filter.md)
  statement combined with
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md)
  did not work ([\#135](https://github.com/bcgov/bcdata/issues/135),
  [\#137](https://github.com/bcgov/bcdata/issues/137),
  [\#131](https://github.com/bcgov/bcdata/issues/131))
- Fixed a bug where layer names with a number in them would not work in
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/reference/bcdc_query_geodata.md)
  ([\#126](https://github.com/bcgov/bcdata/issues/126),
  [\#127](https://github.com/bcgov/bcdata/issues/127))

## bcdata 0.1.1

CRAN release: 2019-11-05

- Expand and standardize checking w\[ms\]f features to make package more
  resistant to slight warehouse API changes.
- Data retrieval functions now work with BCGW name
  ([\#106](https://github.com/bcgov/bcdata/issues/106))
- Add CITATION file
  ([\#104](https://github.com/bcgov/bcdata/issues/104))
- Increased test coverage
  ([\#112](https://github.com/bcgov/bcdata/issues/112))
- Skipping all tests on CRAN that require a web connection
- Better and more informative error message when experiencing http
  failures occur ([\#121](https://github.com/bcgov/bcdata/issues/121))
- Added print methods for `show_query`
- Change examples to donttest
- Added verbose argument to `bcdc_get_record` to enable suppressing
  console writing

## bcdata 0.1.0

- Initial Release
