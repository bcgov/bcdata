## Release summary

This is a minor release, primarily to fix the WARNING on R-devel relating to
S3 generic/method consistency.

### CRAN check issues

The WARNING at https://cran.rstudio.org/web/checks/check_results_bcdata.html
about S3 generic/method consistency has been fixed by ensuring the argument names
are the same in the generics and methods.

## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs.

## revdepcheck results

We checked 1 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
