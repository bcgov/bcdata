### CRAN check issues

* This release comes only a few days after the last release however it is required to fix two important issues:
 - code added to .onLoad() in the last release (0.2.3) was accessing internet resources, and if it failed it would cause a package load failure. This code has been moved to an internal function and is only run when it is required. It fails gracefully with an informative error, and will not cause errors or warnings in R CMD check.
 - testthat is in Suggests, but was previously used unconditionally to run package tests. testthat is now called conditionally and will not run package tests unless it is installed.

## Test environments

* local macOS install (macOS Mojave 10.14.6), R 4.0.4
* local Windows 10 install, R 4.0.5
* ubuntu 18.04 (on github actions), R 4.0.5, 3.6.3, R 3.5
* ubuntu 18.04 (on github actions), R-devel (2021-04-20 r80202)
* Windows Server 2019 (on github actions), R 4.0.5
* macOS Catalina 10.15 (on github actions), R 4.0.5
* win-builder (devel: R version 4.1.0 alpha (2021-04-22 r80209))

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

We checked 1 reverse dependency, comparing R CMD check results across CRAN and dev versions of this package.

We saw 0 new problems
We failed to check 0 packages
