## Resubmission
This is a resubmission. As recommended by the CRAN maintainer who inspected the
package, in this version we have:

* Removed the redundant file LICENSE and its reference in the DESCRIPTION file 
* Changed `\dontrun{}` examples to `\donttest{}`. These examples are long-running
  and/or require internet access and so are liable to create spurious failures.
* Eliminated printing to the console with `cat()` and `print()` functions
  outside of `print()` and `summary()` methods. In the function 
  `bcdc_get_data()`, we made the use of `cat()` calls conditional on a new 
  `verbose` argument (and only then when interactive).

## Test environments
* local OS X install, R 3.6.1
* local Windows 10 install, R 3.6.1
* ubuntu 14.04 (on travis-ci), R 3.6.1, R-oldrel, R-devel
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.
