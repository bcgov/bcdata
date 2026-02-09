# Download and read a resource from a B.C. Data Catalogue record

Download and read a resource from a B.C. Data Catalogue record

## Usage

``` r
bcdc_get_data(record, resource = NULL, verbose = TRUE, ...)
```

## Arguments

- record:

  either a `bcdc_record` object (from the result of
  [`bcdc_get_record()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_get_record.md)),
  a character string denoting the name or ID of a resource (or the URL)
  or a BC Geographic Warehouse (BCGW) name.

  It is advised to use the permanent ID for a record or the BCGW name
  rather than the human-readable name to guard against future name
  changes of the record. If you use the human-readable name a warning
  will be issued once per session. You can silence these warnings
  altogether by setting an option:
  `options("silence_named_get_data_warning" = TRUE)` - which you can set
  in your .Rprofile file so the option persists across sessions.

- resource:

  optional argument used when there are multiple data files within the
  same record. See examples.

- verbose:

  When more than one resource is available for a record, should extra
  information about those resources be printed to the console? Default
  `TRUE`

- ...:

  arguments passed to other functions. Tabular data is passed to a
  function to handle the import based on the file extension.
  [`bcdc_read_functions()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_read_functions.md)
  provides details on which functions handle the data import. You can
  then use this information to look at the help pages of those
  functions. See the examples for a workflow that illustrates this
  process. For spatial Web Feature Service data the `...` arguments are
  passed to
  [`bcdc_query_geodata()`](https://bcgov.github.io/bcdata/dev/reference/bcdc_query_geodata.md).

## Value

An object of a type relevant to the resource (usually a tibble or an sf
object, a list if the resource is a json file)

## Examples

``` r
# \donttest{
# Using the record and resource ID:
try(
  bcdc_get_data(record = '76b1b7a3-2112-4444-857a-afccf7b20da8',
                resource = '4d0377d9-e8a1-429b-824f-0ce8f363512c')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_get_data('1d21922b-ec4f-42e5-8f6b-bf320a286157')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

# Using a `bcdc_record` object obtained from `bcdc_get_record`:
try(
  record <- bcdc_get_record('1d21922b-ec4f-42e5-8f6b-bf320a286157')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

try(
  bcdc_get_data(record)
)
#> Error in eval(expr, envir) : object 'record' not found

# Using a BCGW name
try(
  bcdc_get_data("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [openmaps.gov.bc.ca]:
#> Failed to connect to openmaps.gov.bc.ca port 443 after 10001 ms: Timeout was reached

# Using sf's sql querying ability
try(
  bcdc_get_data(
    record = '30aeb5c1-4285-46c8-b60b-15b1a6f4258b',
    resource = '3d72cf36-ab53-4a2a-9988-a883d7488384',
    layer = 'BC_Boundary_Terrestrial_Line',
    query = "SELECT SHAPE_Length, geom FROM BC_Boundary_Terrestrial_Line WHERE SHAPE_Length < 100"
  )
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

## Example of correcting import problems

## Some initial problems reading in the data
try(
  bcdc_get_data('d7e6c8c7-052f-4f06-b178-74c02c243ea4')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

## From bcdc_get_record we realize that the data is in xlsx format
try(
 bcdc_get_record('8620ce82-4943-43c4-9932-40730a0255d6')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

## bcdc_read_functions let's us know that bcdata
## uses readxl::read_excel to import xlsx files
try(
 bcdc_read_functions()
)
#> # A tibble: 12 × 3
#>    format  package  fun      
#>    <chr>   <chr>    <chr>    
#>  1 kml     sf       read_sf  
#>  2 geojson sf       read_sf  
#>  3 gpkg    sf       read_sf  
#>  4 gdb     sf       read_sf  
#>  5 fgdb    sf       read_sf  
#>  6 shp     sf       read_sf  
#>  7 csv     readr    read_csv 
#>  8 txt     readr    read_tsv 
#>  9 tsv     readr    read_tsv 
#> 10 xlsx    readxl   read_xlsx
#> 11 xls     readxl   read_xls 
#> 12 json    jsonlite read_json

## bcdata let's you know that this resource has
## multiple worksheets
try(
 bcdc_get_data('8620ce82-4943-43c4-9932-40730a0255d6')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

## we can control what is read in from an excel file
## using arguments from readxl::read_excel
try(
  bcdc_get_data('8620ce82-4943-43c4-9932-40730a0255d6', sheet = 'Regional Districts')
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
# }

## Pass an argument through to a read_* function

try(
  bcdc_get_data(record = "a2a2130b-e853-49e8-9b30-1d0c735aa3d9",
                resource = "0b9e7d31-91ff-4146-a473-106a3b301964")
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached

## we can control some properties of the list object returned by
## jsonlite::read_json by setting simplifyVector = TRUE or
## simplifyDataframe = TRUE
try(
 bcdc_get_data(record = "a2a2130b-e853-49e8-9b30-1d0c735aa3d9",
                resource = "0b9e7d31-91ff-4146-a473-106a3b301964",
                simplifyVector = TRUE)
)
#> Error in curl::curl_fetch_memory(x$url$url, handle = x$url$handle) : 
#>   Timeout was reached [catalogue.data.gov.bc.ca]:
#> Failed to connect to catalogue.data.gov.bc.ca port 443 after 10002 ms: Timeout was reached
```
