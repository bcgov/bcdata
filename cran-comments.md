### IMPROVEMENTS
* Added `bcdc_list_groups` and `bcdc_list_group_records` to provide the ability to query on the group endpoint of the catalogue API. #234
* Added new option `bcdata.single_download_limit` to enable setting the maximum number of records an object can be before forcing a paginated download (#252)

### BUG FIXES
* Fixed bug in `collect.bcdc_promise` where the wrong parameter name in `crul::Paginator$new()` resulted in an error in paginated wfs requests (#250, thanks @meztez)
* Fixed a bug where the name of `bcdata.chunk_limit` option had a typo, so that it was not actually used properly (#252)

## Test environments
* local macOS install (macOS Mojave 10.14.6), R 4.0.2
* local Windows 10 install, R 4.0.3
* ubuntu 18.04 (on github actions), R 4.0.3, 3.6.3, R 3.5
* ubuntu 18.04 (on github actions), R-devel (2020-10-20 r79356)
* Windows Server 2019 (on github actions), R 4.0.3
* macOS Catalina 10.15 (on github actions), R 4.0.3
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 note

