# Load the B.C. Data Catalogue URL into an HTML browser

This is a wrapper around utils::browseURL with the URL for the B.C. Data
Catalogue as the default

## Usage

``` r
bcdc_browse(
  query = NULL,
  browser = getOption("browser"),
  encodeIfNeeded = FALSE
)
```

## Arguments

- query:

  Default (NULL) opens a browser to `https://catalogue.data.gov.bc.ca`.
  This argument will also accept a B.C. Data Catalogue record ID or name
  to take you directly to that page. If the provided ID or name doesn't
  lead to a valid webpage, bcdc_browse will search the data catalogue
  for that string.

- browser:

  a non-empty character string giving the name of the program to be used
  as the HTML browser. It should be in the PATH, or a full path
  specified. Alternatively, an R function to be called to invoke the
  browser.

  Under Windows `NULL` is also allowed (and is the default), and implies
  that the file association mechanism will be used.

- encodeIfNeeded:

  Should the URL be encoded by
  [`URLencode`](https://rdrr.io/r/utils/URLencode.html) before passing
  to the browser? This is not needed (and might be harmful) if the
  `browser` program/function itself does encoding, and can be harmful
  for `file://` URLs on some systems and for `http://` URLs passed to
  some CGI applications. Fortunately, most URLs do not need encoding.

## Value

A browser is opened with the B.C. Data Catalogue URL loaded if the
session is interactive. The URL used is returned as a character string.

## See also

[`browseURL`](https://rdrr.io/r/utils/browseURL.html)

## Examples

``` r
# \donttest{
## Take me to the B.C. Data Catalogue home page
try(
  bcdc_browse()
)

## Take me to the B.C. airports catalogue record
try(
 bcdc_browse("bc-airports")
)

## Take me to the B.C. airports catalogue record
try(
  bcdc_browse("76b1b7a3-2112-4444-857a-afccf7b20da8")
)
# }
```
