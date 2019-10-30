## Resubmission
This is a resubmission. In this version I have:

* Removed the redundant file LICENSE and its reference in the DESCRIPTION file 
* Changed `\dontrun{}` examples to `\donttest{}` 
* Changed `cat()` and `print()` calls to `message()` or `warning()` when used 
  outside of `print()` and `summary()` methods. In the function 
  `bcdc_get_data()`, I made the use of `cat()` calls conditional on a new 
  `verbose` argument (and only then when interactive).

## Test environments
* local OS X install, R 3.6.1
* local Windows 10 install, R 3.6.1
* ubuntu 14.04 (on travis-ci), R 3.6.1, R-oldrel, R-devel
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.
