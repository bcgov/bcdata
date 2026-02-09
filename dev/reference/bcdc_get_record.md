# Show a single B.C. Data Catalogue record

Show a single B.C. Data Catalogue record

## Usage

``` r
bcdc_get_record(id)
```

## Arguments

- id:

  the human-readable name, permalink ID, or URL of the record.

  It is advised to use the permanent ID for a record rather than the
  human-readable name to guard against future name changes of the
  record. If you use the human-readable name a warning will be issued
  once per session. You can silence these warnings altogether by setting
  an option: `options("silence_named_get_record_warning" = TRUE)` -
  which you can put in your .Rprofile file so the option persists across
  sessions.

## Value

A list containing the metadata for the record

## Examples

``` r
# \donttest{
try(
  bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/bc-airports")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_get_record("bc-airports")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_get_record("76b1b7a3-2112-4444-857a-afccf7b20da8")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }
```
