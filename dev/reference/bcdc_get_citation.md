# Generate a bibentry from a Data Catalogue Record

Generate a "TechReport" bibentry object directly from a catalogue
record. The primary use of this function is as a helper to create a
`.bib` file for use in reference management software to cite data from
the B.C. Data Catalogue. This function is likely to be starting place
for this process and manual adjustment will often be needed. The
bibentries are not designed to be authoritative and may not reflect all
fields required for individual citation requirements.

## Usage

``` r
bcdc_get_citation(record)
```

## Arguments

- record:

  either a `bcdc_record` object (from the result of
  [`bcdc_get_record()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_get_record.md)),
  a character string denoting the name or ID of a resource (or the URL)

  It is advised to use the permanent ID for a record rather than the
  human-readable name to guard against future name changes of the
  record. If you use the human-readable name a warning will be issued
  once per session. You can silence these warnings altogether by setting
  an option: `options("silence_named_get_data_warning" = TRUE)` - which
  you can set in your .Rprofile file so the option persists across
  sessions.

## See also

[`utils::bibentry()`](https://rdrr.io/r/utils/bibentry.html)

## Examples

``` r
try(
 bcdc_get_citation("76b1b7a3-2112-4444-857a-afccf7b20da8")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10003 ms: Timeout was reached

## Or directly on a record object
try(
 bcdc_get_citation(bcdc_get_record("76b1b7a3-2112-4444-857a-afccf7b20da8"))
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
```
