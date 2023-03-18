## Release summary

This is a patch release, primarily to fix the WARNING on R-devel relating to
S3 generic/method consistency.

### CRAN check issues

We fixed the CRAN check result failures, in particular:

 * We fixed the S3 method inconsistencies for `sql_translation()`.

## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs.

## revdepcheck results

We checked 1 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
