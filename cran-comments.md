## CRAN check issues

* Fixed this warning: https://www.r-project.org/nosvn/R.check/r-devel-linux-x86_64-fedora-clang/bcdata-00check.html
We are now precompiling vignettes so that functions are run locally and not on CRAN. This will ensure 
that any outages in the data source will not cause false positive for CRAN checks.
* Fixed this note: https://www.r-project.org/nosvn/R.check/r-devel-linux-x86_64-fedora-gcc/bcdata-00check.html
We are now explicitly importing `methods::setoldClass`


## Test environments
* local OS X install, R 3.6.1
* local Windows 10 install, R 3.6.1
* ubuntu 16.04 (on travis-ci), R 3.6.1, R-oldrel, R-devel
* ubuntu 16.04 (on github actions), R 3.6, R 3.5, R 3.4, R 3.3
* windows-latest (on github actions), R 3.6.1
* macOS-latest (on github actions), R 3.6.1
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 0 note

