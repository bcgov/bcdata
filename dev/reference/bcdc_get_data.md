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
#> Simple feature collection with 451 features and 41 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 405790.2 ymin: 367957.6 xmax: 1796772 ymax: 1688614
#> Projected CRS: NAD83 / BC Albers
#> # A tibble: 451 × 42
#>    id          CUSTODIAN_ORG_DESCRI…¹ BUSINESS_CATEGORY_CL…²
#>  * <chr>       <chr>                  <chr>                 
#>  1 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  2 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  3 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  4 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  5 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  6 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  7 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  8 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  9 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#> 10 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#> # ℹ 441 more rows
#> # ℹ abbreviated names: ¹​CUSTODIAN_ORG_DESCRIPTION,
#> #   ²​BUSINESS_CATEGORY_CLASS
#> # ℹ 39 more variables: BUSINESS_CATEGORY_DESCRIPTION <chr>,
#> #   OCCUPANT_TYPE_DESCRIPTION <chr>, SOURCE_DATA_ID <chr>,
#> #   SUPPLIED_SOURCE_ID_IND <chr>, AIRPORT_NAME <chr>,
#> #   DESCRIPTION <chr>, PHYSICAL_ADDRESS <chr>, …

try(
  bcdc_get_data('1d21922b-ec4f-42e5-8f6b-bf320a286157')
)
#> Error : There are no resources that bcdata can download from this record

# Using a `bcdc_record` object obtained from `bcdc_get_record`:
try(
  record <- bcdc_get_record('1d21922b-ec4f-42e5-8f6b-bf320a286157')
)

try(
  bcdc_get_data(record)
)
#> Error : There are no resources that bcdata can download from this record

# Using a BCGW name
try(
  bcdc_get_data("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
)
#> Simple feature collection with 451 features and 41 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 405790.2 ymin: 367957.6 xmax: 1796772 ymax: 1688614
#> Projected CRS: NAD83 / BC Albers
#> # A tibble: 451 × 42
#>    id          CUSTODIAN_ORG_DESCRI…¹ BUSINESS_CATEGORY_CL…²
#>  * <chr>       <chr>                  <chr>                 
#>  1 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  2 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  3 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  4 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  5 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  6 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  7 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  8 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#>  9 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#> 10 WHSE_IMAGE… "Ministry of Forest, … airTransportation     
#> # ℹ 441 more rows
#> # ℹ abbreviated names: ¹​CUSTODIAN_ORG_DESCRIPTION,
#> #   ²​BUSINESS_CATEGORY_CLASS
#> # ℹ 39 more variables: BUSINESS_CATEGORY_DESCRIPTION <chr>,
#> #   OCCUPANT_TYPE_DESCRIPTION <chr>, SOURCE_DATA_ID <chr>,
#> #   SUPPLIED_SOURCE_ID_IND <chr>, AIRPORT_NAME <chr>,
#> #   DESCRIPTION <chr>, PHYSICAL_ADDRESS <chr>, …

# Using sf's sql querying ability
try(
  bcdc_get_data(
    record = '30aeb5c1-4285-46c8-b60b-15b1a6f4258b',
    resource = '3d72cf36-ab53-4a2a-9988-a883d7488384',
    layer = 'BC_Boundary_Terrestrial_Line',
    query = "SELECT SHAPE_Length, geom FROM BC_Boundary_Terrestrial_Line WHERE SHAPE_Length < 100"
  )
)
#> Reading the data using the read_sf function from the sf package.
#> Warning: argument layer is ignored when query is specified
#> Simple feature collection with 6106 features and 1 field
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: 529420.8 ymin: 367780.7 xmax: 1203949 ymax: 1157953
#> Projected CRS: NAD83 / BC Albers
#> # A tibble: 6,106 × 2
#>    SHAPE_Length                                         geom
#>           <dbl>                             <LINESTRING [m]>
#>  1         79.2 (1183654 367787.5, 1183637 367780.7, 118363…
#>  2         92.8 (1178975 369462.2, 1178962 369460.6, 117895…
#>  3         71.0 (1178340 369486.6, 1178335 369481.4, 117832…
#>  4         80.2 (1182295 369909.3, 1182289 369909.1, 118228…
#>  5         90.7 (1177992 370787.7, 1177986 370785.4, 117797…
#>  6         94.3 (1178597 370831.9, 1178591 370831.7, 117858…
#>  7         75.3 (1178008 371008.1, 1178002 371005.8, 117799…
#>  8         77.4 (1178022 371104.5, 1178017 371100.4, 117801…
#>  9         76.7 (1176492 371248.6, 1176485 371248.3, 117647…
#> 10         87.2 (1178786 371574.1, 1178778 371572.7, 117877…
#> # ℹ 6,096 more rows

## Example of correcting import problems

## Some initial problems reading in the data
try(
  bcdc_get_data('d7e6c8c7-052f-4f06-b178-74c02c243ea4')
)
#> Error : There are no resources that bcdata can download from this record

## From bcdc_get_record we realize that the data is in xlsx format
try(
 bcdc_get_record('8620ce82-4943-43c4-9932-40730a0255d6')
)
#> B.C. Data Catalogue Record: New Homes
#>  Registry (2016-2024)
#> Name: new-homes-registry-2016-2024-
#>  (ID: 8620ce82-4943-43c4-9932-40730a0255d6)
#> Permalink:
#>  https://catalogue.data.gov.bc.ca/dataset/8620ce82-4943-43c4-9932-40730a0255d6
#> Licence: Access Only
#> Description: This dataset contains
#>  information from BC Housing's New Homes Registry.
#> Available Resources (1):
#>  1. New Homes Registrations (2016-2024) (xlsx)
#> Access the full 'Resources' data frame using:
#>  bcdc_tidy_resources('8620ce82-4943-43c4-9932-40730a0255d6')

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
#> Reading the data using the read_xlsx function from the readxl package.
#> 
#> This .xlsx resource contains the following sheets: 
#>  'Notes'
#>  'Single Detached '
#>  'Multi Unit Homes'
#>  'Purpose Built Rental'
#> Defaulting to the 'Notes' sheet. See ?bcdc_get_data for examples on how to specify a sheet.
#> # A tibble: 0 × 0

## we can control what is read in from an excel file
## using arguments from readxl::read_excel
try(
  bcdc_get_data('8620ce82-4943-43c4-9932-40730a0255d6', sheet = 'Regional Districts')
)
#> Reading the data using the read_xlsx function from the readxl package.
#> 
#> This .xlsx resource contains the following sheets: 
#>  'Notes'
#>  'Single Detached '
#>  'Multi Unit Homes'
#>  'Purpose Built Rental'
#> Error : Reading the data set failed with the following error message:
#> 
#>   Error: Sheet 'Regional Districts' not found
#> 
#> The file can be found here:
#>   '/tmp/RtmpOR8She/bcdata_1e196bc18459/file1e198354fd.xlsx'
#> if you would like to try to read it manually.
#> 
# }

## Pass an argument through to a read_* function

try(
  bcdc_get_data(record = "a2a2130b-e853-49e8-9b30-1d0c735aa3d9",
                resource = "0b9e7d31-91ff-4146-a473-106a3b301964")
)
#> Reading the data using the read_json function from the jsonlite package.
#> $openapi
#> [1] "3.0.0"
#> 
#> $servers
#> $servers[[1]]
#> $servers[[1]]$url
#> [1] "https://catalogue.data.gov.bc.ca/api/3"
#> 
#> $servers[[1]]$description
#> [1] "Production"
#> 
#> 
#> $servers[[2]]
#> $servers[[2]]$url
#> [1] "https://cat.data.gov.bc.ca/api/3"
#> 
#> $servers[[2]]$description
#> [1] "Test"
#> 
#> 
#> $servers[[3]]
#> $servers[[3]]$url
#> [1] "https://cad.data.gov.bc.ca/api/3"
#> 
#> $servers[[3]]$description
#> [1] "Delivery"
#> 
#> 
#> 
#> $info
#> $info$title
#> [1] "BC Data Catalogue API"
#> 
#> $info$description
#> [1] "This API provides live access to the BC Data Catalogue. Further documentation on the API is available from http://docs.ckan.org/en/latest/ Confirm the version of the API available from the catalogue by requesting https://catalogue.data.gov.bc.ca/api/3/action/status_show. \n\nPlease note that you may experience issues when submitting requests to the delivery or test environment if using this [OpenAPI specification](https://github.com/bcgov/api-specs) in other API console viewers."
#> 
#> $info$termsOfService
#> [1] "https://www2.gov.bc.ca/gov/content?id=D1EE0A405E584363B205CD4353E02C88"
#> 
#> $info$contact
#> $info$contact$name
#> [1] "Data BC"
#> 
#> $info$contact$url
#> [1] "http://data.gov.bc.ca/"
#> 
#> $info$contact$email
#> [1] "data@gov.bc.ca"
#> 
#> 
#> $info$license
#> $info$license$name
#> [1] "Open Government License - British Columbia"
#> 
#> $info$license$url
#> [1] "https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61"
#> 
#> 
#> $info$version
#> [1] "3.0.1"
#> 
#> 
#> $tags
#> $tags[[1]]
#> $tags[[1]]$name
#> [1] "action"
#> 
#> $tags[[1]]$description
#> [1] "CKAN's Action API is a powerful, RPC-style API that exposes all of CKAN's core features to API clients."
#> 
#> $tags[[1]]$externalDocs
#> $tags[[1]]$externalDocs$description
#> [1] "Find out more"
#> 
#> $tags[[1]]$externalDocs$url
#> [1] "http://docs.ckan.org/en/ckan-2.5.3/api/index.html"
#> 
#> 
#> 
#> 
#> $security
#> $security[[1]]
#> $security[[1]]$githubAccessCode
#> $security[[1]]$githubAccessCode[[1]]
#> [1] "user"
#> 
#> $security[[1]]$githubAccessCode[[2]]
#> [1] "user:email"
#> 
#> $security[[1]]$githubAccessCode[[3]]
#> [1] "user:follow"
#> 
#> $security[[1]]$githubAccessCode[[4]]
#> [1] "public_repo"
#> 
#> $security[[1]]$githubAccessCode[[5]]
#> [1] "repo"
#> 
#> $security[[1]]$githubAccessCode[[6]]
#> [1] "repo_deployment"
#> 
#> $security[[1]]$githubAccessCode[[7]]
#> [1] "repo:status"
#> 
#> $security[[1]]$githubAccessCode[[8]]
#> [1] "delete_repo"
#> 
#> $security[[1]]$githubAccessCode[[9]]
#> [1] "notifications"
#> 
#> $security[[1]]$githubAccessCode[[10]]
#> [1] "gist"
#> 
#> $security[[1]]$githubAccessCode[[11]]
#> [1] "read:repo_hook"
#> 
#> $security[[1]]$githubAccessCode[[12]]
#> [1] "write:repo_hook"
#> 
#> $security[[1]]$githubAccessCode[[13]]
#> [1] "admin:repo_hook"
#> 
#> $security[[1]]$githubAccessCode[[14]]
#> [1] "read:org"
#> 
#> $security[[1]]$githubAccessCode[[15]]
#> [1] "write:org"
#> 
#> $security[[1]]$githubAccessCode[[16]]
#> [1] "admin:org"
#> 
#> $security[[1]]$githubAccessCode[[17]]
#> [1] "read:public_key"
#> 
#> $security[[1]]$githubAccessCode[[18]]
#> [1] "write:public_key"
#> 
#> $security[[1]]$githubAccessCode[[19]]
#> [1] "admin:public_key"
#> 
#> 
#> 
#> $security[[2]]
#> $security[[2]]$internalApiKey
#> list()
#> 
#> 
#> 
#> $paths
#> $paths$`/action/tag_list`
#> $paths$`/action/tag_list`$get
#> $paths$`/action/tag_list`$get$summary
#> [1] "Get a list of tags"
#> 
#> $paths$`/action/tag_list`$get$description
#> [1] "Returns the names of all indexed tags"
#> 
#> $paths$`/action/tag_list`$get$parameters
#> $paths$`/action/tag_list`$get$parameters[[1]]
#> $paths$`/action/tag_list`$get$parameters[[1]]$name
#> [1] "offset"
#> 
#> $paths$`/action/tag_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/tag_list`$get$parameters[[1]]$description
#> [1] "The offset (index) of the first tag to return"
#> 
#> $paths$`/action/tag_list`$get$parameters[[1]]$schema
#> $paths$`/action/tag_list`$get$parameters[[1]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/tag_list`$get$parameters[[1]]$schema$default
#> [1] 0
#> 
#> 
#> 
#> $paths$`/action/tag_list`$get$parameters[[2]]
#> $paths$`/action/tag_list`$get$parameters[[2]]$name
#> [1] "limit"
#> 
#> $paths$`/action/tag_list`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/tag_list`$get$parameters[[2]]$description
#> [1] "The number of tags to be returned per page"
#> 
#> $paths$`/action/tag_list`$get$parameters[[2]]$schema
#> $paths$`/action/tag_list`$get$parameters[[2]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/tag_list`$get$parameters[[2]]$schema$default
#> [1] 100
#> 
#> 
#> 
#> 
#> $paths$`/action/tag_list`$get$tags
#> $paths$`/action/tag_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/tag_list`$get$responses
#> $paths$`/action/tag_list`$get$responses$`200`
#> $paths$`/action/tag_list`$get$responses$`200`$description
#> [1] "List of tags"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/status_show`
#> $paths$`/action/status_show`$get
#> $paths$`/action/status_show`$get$summary
#> [1] "Get the site status"
#> 
#> $paths$`/action/status_show`$get$description
#> [1] "Returns the site status"
#> 
#> $paths$`/action/status_show`$get$tags
#> $paths$`/action/status_show`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/status_show`$get$responses
#> $paths$`/action/status_show`$get$responses$`200`
#> $paths$`/action/status_show`$get$responses$`200`$description
#> [1] "Returns the site status, version, installed extensions"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_list`
#> $paths$`/action/package_list`$get
#> $paths$`/action/package_list`$get$summary
#> [1] "Get a list of all packages (datasets)"
#> 
#> $paths$`/action/package_list`$get$description
#> [1] "Returns the names of all indexed packages (datasets)"
#> 
#> $paths$`/action/package_list`$get$parameters
#> $paths$`/action/package_list`$get$parameters[[1]]
#> $paths$`/action/package_list`$get$parameters[[1]]$name
#> [1] "offset"
#> 
#> $paths$`/action/package_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_list`$get$parameters[[1]]$description
#> [1] "The offset (index) of the first package to return"
#> 
#> $paths$`/action/package_list`$get$parameters[[1]]$schema
#> $paths$`/action/package_list`$get$parameters[[1]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/package_list`$get$parameters[[1]]$schema$default
#> [1] 0
#> 
#> 
#> 
#> $paths$`/action/package_list`$get$parameters[[2]]
#> $paths$`/action/package_list`$get$parameters[[2]]$name
#> [1] "limit"
#> 
#> $paths$`/action/package_list`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_list`$get$parameters[[2]]$description
#> [1] "The number of packages to be returned per page"
#> 
#> $paths$`/action/package_list`$get$parameters[[2]]$schema
#> $paths$`/action/package_list`$get$parameters[[2]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/package_list`$get$parameters[[2]]$schema$default
#> [1] 100
#> 
#> 
#> 
#> 
#> $paths$`/action/package_list`$get$tags
#> $paths$`/action/package_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/package_list`$get$responses
#> $paths$`/action/package_list`$get$responses$`200`
#> $paths$`/action/package_list`$get$responses$`200`$description
#> [1] "List of packages"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_search`
#> $paths$`/action/package_search`$get
#> $paths$`/action/package_search`$get$summary
#> [1] "Find packages (datasets) matching query terms"
#> 
#> $paths$`/action/package_search`$get$description
#> [1] "Searches for packages (datasets) matching the specified query terms"
#> 
#> $paths$`/action/package_search`$get$parameters
#> $paths$`/action/package_search`$get$parameters[[1]]
#> $paths$`/action/package_search`$get$parameters[[1]]$name
#> [1] "q"
#> 
#> $paths$`/action/package_search`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_search`$get$parameters[[1]]$description
#> [1] "A query string"
#> 
#> $paths$`/action/package_search`$get$parameters[[1]]$schema
#> $paths$`/action/package_search`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/package_search`$get$parameters[[1]]$schema$default
#> [1] "\"Okanagan Lake\""
#> 
#> 
#> 
#> 
#> $paths$`/action/package_search`$get$tags
#> $paths$`/action/package_search`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/package_search`$get$responses
#> $paths$`/action/package_search`$get$responses$`200`
#> $paths$`/action/package_search`$get$responses$`200`$description
#> [1] "List of packages"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_show`
#> $paths$`/action/package_show`$get
#> $paths$`/action/package_show`$get$summary
#> [1] "Get metadata about one specific package (dataset)"
#> 
#> $paths$`/action/package_show`$get$description
#> [1] "Returns metadata about the package (dataset) corresponding to the specified unique name"
#> 
#> $paths$`/action/package_show`$get$parameters
#> $paths$`/action/package_show`$get$parameters[[1]]
#> $paths$`/action/package_show`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/package_show`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_show`$get$parameters[[1]]$description
#> [1] "The package name"
#> 
#> $paths$`/action/package_show`$get$parameters[[1]]$schema
#> $paths$`/action/package_show`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/package_show`$get$parameters[[1]]$schema$default
#> [1] "grizzly-bear-population-units"
#> 
#> 
#> 
#> 
#> $paths$`/action/package_show`$get$tags
#> $paths$`/action/package_show`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/package_show`$get$responses
#> $paths$`/action/package_show`$get$responses$`200`
#> $paths$`/action/package_show`$get$responses$`200`$description
#> [1] "A package metadata object"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_activity_list`
#> $paths$`/action/package_activity_list`$get
#> $paths$`/action/package_activity_list`$get$summary
#> [1] "Get the activity stream of a package (dataset)"
#> 
#> $paths$`/action/package_activity_list`$get$description
#> [1] "Returns a package's activity stream"
#> 
#> $paths$`/action/package_activity_list`$get$parameters
#> $paths$`/action/package_activity_list`$get$parameters[[1]]
#> $paths$`/action/package_activity_list`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[1]]$description
#> [1] "The id or name of the package"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[1]]$schema
#> $paths$`/action/package_activity_list`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[1]]$schema$default
#> [1] "grizzly-bear-population-units"
#> 
#> 
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[2]]
#> $paths$`/action/package_activity_list`$get$parameters[[2]]$name
#> [1] "offset"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[2]]$description
#> [1] "Where to start getting activity items from"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[2]]$schema
#> $paths$`/action/package_activity_list`$get$parameters[[2]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[2]]$schema$default
#> [1] 0
#> 
#> 
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[3]]
#> $paths$`/action/package_activity_list`$get$parameters[[3]]$name
#> [1] "limit"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[3]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[3]]$description
#> [1] "The maximum number of activities to return"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[3]]$schema
#> $paths$`/action/package_activity_list`$get$parameters[[3]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/package_activity_list`$get$parameters[[3]]$schema$default
#> [1] 31
#> 
#> 
#> 
#> 
#> $paths$`/action/package_activity_list`$get$tags
#> $paths$`/action/package_activity_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/package_activity_list`$get$responses
#> $paths$`/action/package_activity_list`$get$responses$`200`
#> $paths$`/action/package_activity_list`$get$responses$`200`$description
#> [1] "List of activities"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_activity_list_html`
#> $paths$`/action/package_activity_list_html`$get
#> $paths$`/action/package_activity_list_html`$get$summary
#> [1] "Get the activity stream of a package (dataset), HTML format"
#> 
#> $paths$`/action/package_activity_list_html`$get$description
#> [1] "The activity stream is rendered as a snippet of HTML meant to be included in an HTML pag, i.e it doesn't have any header or footer."
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters
#> $paths$`/action/package_activity_list_html`$get$parameters[[1]]
#> $paths$`/action/package_activity_list_html`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[1]]$description
#> [1] "The id or name of the package"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[1]]$schema
#> $paths$`/action/package_activity_list_html`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[1]]$schema$default
#> [1] "grizzly-bear-population-units"
#> 
#> 
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[2]]
#> $paths$`/action/package_activity_list_html`$get$parameters[[2]]$name
#> [1] "offset"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[2]]$description
#> [1] "Where to start getting activity items from"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[2]]$schema
#> $paths$`/action/package_activity_list_html`$get$parameters[[2]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[2]]$schema$default
#> [1] 0
#> 
#> 
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[3]]
#> $paths$`/action/package_activity_list_html`$get$parameters[[3]]$name
#> [1] "limit"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[3]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[3]]$description
#> [1] "The maximum number of activities to return"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[3]]$schema
#> $paths$`/action/package_activity_list_html`$get$parameters[[3]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters[[3]]$schema$default
#> [1] 31
#> 
#> 
#> 
#> 
#> $paths$`/action/package_activity_list_html`$get$tags
#> $paths$`/action/package_activity_list_html`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/package_activity_list_html`$get$responses
#> $paths$`/action/package_activity_list_html`$get$responses$`200`
#> $paths$`/action/package_activity_list_html`$get$responses$`200`$description
#> [1] "List of activities rendered as HTML snippet"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_autocomplete`
#> $paths$`/action/package_autocomplete`$get
#> $paths$`/action/package_autocomplete`$get$summary
#> [1] "Find packages (datasets) matching a query"
#> 
#> $paths$`/action/package_autocomplete`$get$description
#> [1] "Return a list of datasets that match a string"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters
#> $paths$`/action/package_autocomplete`$get$parameters[[1]]
#> $paths$`/action/package_autocomplete`$get$parameters[[1]]$name
#> [1] "q"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[1]]$description
#> [1] "The string to query"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[1]]$schema
#> $paths$`/action/package_autocomplete`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[1]]$schema$default
#> [1] "\"Okanagan Lake\""
#> 
#> 
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[2]]
#> $paths$`/action/package_autocomplete`$get$parameters[[2]]$name
#> [1] "limit"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[2]]$description
#> [1] "The maximum number of resource formats to return"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[2]]$schema
#> $paths$`/action/package_autocomplete`$get$parameters[[2]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters[[2]]$schema$default
#> [1] 10
#> 
#> 
#> 
#> 
#> $paths$`/action/package_autocomplete`$get$tags
#> $paths$`/action/package_autocomplete`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/package_autocomplete`$get$responses
#> $paths$`/action/package_autocomplete`$get$responses$`200`
#> $paths$`/action/package_autocomplete`$get$responses$`200`$description
#> [1] "List of datasets that match a string"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_relationships_list`
#> $paths$`/action/package_relationships_list`$get
#> $paths$`/action/package_relationships_list`$get$summary
#> [1] "Get package (dataset) relationships"
#> 
#> $paths$`/action/package_relationships_list`$get$description
#> [1] "Return a dataset's relationships"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters
#> $paths$`/action/package_relationships_list`$get$parameters[[1]]
#> $paths$`/action/package_relationships_list`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[1]]$description
#> [1] "The id or name of the first package"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[1]]$schema
#> $paths$`/action/package_relationships_list`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[1]]$schema$default
#> [1] "grizzly-bear-population-units"
#> 
#> 
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[2]]
#> $paths$`/action/package_relationships_list`$get$parameters[[2]]$name
#> [1] "id2"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[2]]$description
#> [1] "The id or name of the second package"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[2]]$schema
#> $paths$`/action/package_relationships_list`$get$parameters[[2]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[2]]$schema$default
#> [1] "important-fossil-areas"
#> 
#> 
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[3]]
#> $paths$`/action/package_relationships_list`$get$parameters[[3]]$name
#> [1] "rel"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[3]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[3]]$description
#> [1] "relationship as string"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters[[3]]$schema
#> $paths$`/action/package_relationships_list`$get$parameters[[3]]$schema$type
#> [1] "string"
#> 
#> 
#> 
#> 
#> $paths$`/action/package_relationships_list`$get$tags
#> $paths$`/action/package_relationships_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/package_relationships_list`$get$responses
#> $paths$`/action/package_relationships_list`$get$responses$`200`
#> $paths$`/action/package_relationships_list`$get$responses$`200`$description
#> [1] "List of dataset relationships"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_revision_list`
#> $paths$`/action/package_revision_list`$get
#> $paths$`/action/package_revision_list`$get$summary
#> [1] "Get list of revisions for a package (dataset)"
#> 
#> $paths$`/action/package_revision_list`$get$description
#> [1] "Return a dataset's revision as a list of dictionaries"
#> 
#> $paths$`/action/package_revision_list`$get$parameters
#> $paths$`/action/package_revision_list`$get$parameters[[1]]
#> $paths$`/action/package_revision_list`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/package_revision_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/package_revision_list`$get$parameters[[1]]$description
#> [1] "The id or name of the dataset"
#> 
#> $paths$`/action/package_revision_list`$get$parameters[[1]]$schema
#> $paths$`/action/package_revision_list`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/package_revision_list`$get$parameters[[1]]$schema$default
#> [1] "grizzly-bear-population-units"
#> 
#> 
#> 
#> 
#> $paths$`/action/package_revision_list`$get$tags
#> $paths$`/action/package_revision_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/package_revision_list`$get$responses
#> $paths$`/action/package_revision_list`$get$responses$`200`
#> $paths$`/action/package_revision_list`$get$responses$`200`$description
#> [1] "List of dataset revisions"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_activity_list`
#> $paths$`/action/organization_activity_list`$get
#> $paths$`/action/organization_activity_list`$get$summary
#> [1] "Get the activity stream of an organization"
#> 
#> $paths$`/action/organization_activity_list`$get$description
#> [1] "Return an organization's activity stream"
#> 
#> $paths$`/action/organization_activity_list`$get$parameters
#> $paths$`/action/organization_activity_list`$get$parameters[[1]]
#> $paths$`/action/organization_activity_list`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/organization_activity_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_activity_list`$get$parameters[[1]]$description
#> [1] "The id or name of the organization"
#> 
#> $paths$`/action/organization_activity_list`$get$parameters[[1]]$schema
#> $paths$`/action/organization_activity_list`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/organization_activity_list`$get$parameters[[1]]$schema$default
#> [1] "ministry-of-agriculture"
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_activity_list`$get$tags
#> $paths$`/action/organization_activity_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_activity_list`$get$responses
#> $paths$`/action/organization_activity_list`$get$responses$`200`
#> $paths$`/action/organization_activity_list`$get$responses$`200`$description
#> [1] "List of an organization's activities"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_activity_list_html`
#> $paths$`/action/organization_activity_list_html`$get
#> $paths$`/action/organization_activity_list_html`$get$summary
#> [1] "Get the activity stream of an organization, HTML format"
#> 
#> $paths$`/action/organization_activity_list_html`$get$description
#> [1] "Return an organization's activity stream as HTML"
#> 
#> $paths$`/action/organization_activity_list_html`$get$parameters
#> $paths$`/action/organization_activity_list_html`$get$parameters[[1]]
#> $paths$`/action/organization_activity_list_html`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/organization_activity_list_html`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_activity_list_html`$get$parameters[[1]]$description
#> [1] "The id or name of the organization"
#> 
#> $paths$`/action/organization_activity_list_html`$get$parameters[[1]]$schema
#> $paths$`/action/organization_activity_list_html`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/organization_activity_list_html`$get$parameters[[1]]$schema$default
#> [1] "ministry-of-agriculture"
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_activity_list_html`$get$tags
#> $paths$`/action/organization_activity_list_html`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_activity_list_html`$get$responses
#> $paths$`/action/organization_activity_list_html`$get$responses$`200`
#> $paths$`/action/organization_activity_list_html`$get$responses$`200`$description
#> [1] "List of an organization's activities in HTML"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_follower_count`
#> $paths$`/action/organization_follower_count`$get
#> $paths$`/action/organization_follower_count`$get$summary
#> [1] "Get number of followers of an organization"
#> 
#> $paths$`/action/organization_follower_count`$get$description
#> [1] "Return the number of followers of an organization"
#> 
#> $paths$`/action/organization_follower_count`$get$parameters
#> $paths$`/action/organization_follower_count`$get$parameters[[1]]
#> $paths$`/action/organization_follower_count`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/organization_follower_count`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_follower_count`$get$parameters[[1]]$description
#> [1] "The id or name of the organization"
#> 
#> $paths$`/action/organization_follower_count`$get$parameters[[1]]$schema
#> $paths$`/action/organization_follower_count`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/organization_follower_count`$get$parameters[[1]]$schema$default
#> [1] "ministry-of-agriculture"
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_follower_count`$get$tags
#> $paths$`/action/organization_follower_count`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_follower_count`$get$responses
#> $paths$`/action/organization_follower_count`$get$responses$`200`
#> $paths$`/action/organization_follower_count`$get$responses$`200`$description
#> [1] "Count of organization followers"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_follower_list`
#> $paths$`/action/organization_follower_list`$get
#> $paths$`/action/organization_follower_list`$get$summary
#> [1] "Get users following an organization"
#> 
#> $paths$`/action/organization_follower_list`$get$description
#> [1] "Return a list of users that are following a given organization"
#> 
#> $paths$`/action/organization_follower_list`$get$parameters
#> $paths$`/action/organization_follower_list`$get$parameters[[1]]
#> $paths$`/action/organization_follower_list`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/organization_follower_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_follower_list`$get$parameters[[1]]$description
#> [1] "The id or name of the organization"
#> 
#> $paths$`/action/organization_follower_list`$get$parameters[[1]]$schema
#> $paths$`/action/organization_follower_list`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/organization_follower_list`$get$parameters[[1]]$schema$default
#> [1] "ministry-of-agriculture"
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_follower_list`$get$tags
#> $paths$`/action/organization_follower_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_follower_list`$get$responses
#> $paths$`/action/organization_follower_list`$get$responses$`200`
#> $paths$`/action/organization_follower_list`$get$responses$`200`$description
#> [1] "List of organization followers"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_list_for_user`
#> $paths$`/action/organization_list_for_user`$get
#> $paths$`/action/organization_list_for_user`$get$summary
#> [1] "Get organizations that a user has a given permission for"
#> 
#> $paths$`/action/organization_list_for_user`$get$description
#> [1] "Return the organizations that the user has a given permission for"
#> 
#> $paths$`/action/organization_list_for_user`$get$parameters
#> $paths$`/action/organization_list_for_user`$get$parameters[[1]]
#> $paths$`/action/organization_list_for_user`$get$parameters[[1]]$name
#> [1] "permission"
#> 
#> $paths$`/action/organization_list_for_user`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_list_for_user`$get$parameters[[1]]$description
#> [1] "The permission the user has against the returned organization"
#> 
#> $paths$`/action/organization_list_for_user`$get$parameters[[1]]$schema
#> $paths$`/action/organization_list_for_user`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/organization_list_for_user`$get$parameters[[1]]$schema$default
#> [1] "\"edit_group\""
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_list_for_user`$get$tags
#> $paths$`/action/organization_list_for_user`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_list_for_user`$get$responses
#> $paths$`/action/organization_list_for_user`$get$responses$`200`
#> $paths$`/action/organization_list_for_user`$get$responses$`200`$description
#> [1] "List of organizations for given permission"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_revision_list`
#> $paths$`/action/organization_revision_list`$get
#> $paths$`/action/organization_revision_list`$get$summary
#> [1] "Get organization revisions"
#> 
#> $paths$`/action/organization_revision_list`$get$description
#> [1] "Return an organization's revisions"
#> 
#> $paths$`/action/organization_revision_list`$get$parameters
#> $paths$`/action/organization_revision_list`$get$parameters[[1]]
#> $paths$`/action/organization_revision_list`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/organization_revision_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_revision_list`$get$parameters[[1]]$description
#> [1] "The name or id of the organization"
#> 
#> $paths$`/action/organization_revision_list`$get$parameters[[1]]$schema
#> $paths$`/action/organization_revision_list`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/organization_revision_list`$get$parameters[[1]]$schema$default
#> [1] "ministry-of-agriculture"
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_revision_list`$get$tags
#> $paths$`/action/organization_revision_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_revision_list`$get$responses
#> $paths$`/action/organization_revision_list`$get$responses$`200`
#> $paths$`/action/organization_revision_list`$get$responses$`200`$description
#> [1] "List of an organization's revisions"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_show`
#> $paths$`/action/organization_show`$get
#> $paths$`/action/organization_show`$get$summary
#> [1] "Get details of a specific organization"
#> 
#> $paths$`/action/organization_show`$get$description
#> [1] "Return the details of an organization"
#> 
#> $paths$`/action/organization_show`$get$parameters
#> $paths$`/action/organization_show`$get$parameters[[1]]
#> $paths$`/action/organization_show`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/organization_show`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_show`$get$parameters[[1]]$description
#> [1] "The id or name of the organization"
#> 
#> $paths$`/action/organization_show`$get$parameters[[1]]$schema
#> $paths$`/action/organization_show`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/organization_show`$get$parameters[[1]]$schema$default
#> [1] "ministry-of-agriculture"
#> 
#> 
#> 
#> $paths$`/action/organization_show`$get$parameters[[2]]
#> $paths$`/action/organization_show`$get$parameters[[2]]$name
#> [1] "include_datasets"
#> 
#> $paths$`/action/organization_show`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_show`$get$parameters[[2]]$description
#> [1] "include a list of the organization's datasets"
#> 
#> $paths$`/action/organization_show`$get$parameters[[2]]$schema
#> $paths$`/action/organization_show`$get$parameters[[2]]$schema$type
#> [1] "boolean"
#> 
#> $paths$`/action/organization_show`$get$parameters[[2]]$schema$default
#> [1] TRUE
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_show`$get$tags
#> $paths$`/action/organization_show`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_show`$get$responses
#> $paths$`/action/organization_show`$get$responses$`200`
#> $paths$`/action/organization_show`$get$responses$`200`$description
#> [1] "List organization details"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_list`
#> $paths$`/action/organization_list`$get
#> $paths$`/action/organization_list`$get$summary
#> [1] "Get names of all organizations"
#> 
#> $paths$`/action/organization_list`$get$description
#> [1] "Returns the names of all indexed organizations"
#> 
#> $paths$`/action/organization_list`$get$parameters
#> $paths$`/action/organization_list`$get$parameters[[1]]
#> $paths$`/action/organization_list`$get$parameters[[1]]$name
#> [1] "offset"
#> 
#> $paths$`/action/organization_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_list`$get$parameters[[1]]$description
#> [1] "The offset (index) of the first organizations to return"
#> 
#> $paths$`/action/organization_list`$get$parameters[[1]]$schema
#> $paths$`/action/organization_list`$get$parameters[[1]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/organization_list`$get$parameters[[1]]$schema$default
#> [1] 0
#> 
#> 
#> 
#> $paths$`/action/organization_list`$get$parameters[[2]]
#> $paths$`/action/organization_list`$get$parameters[[2]]$name
#> [1] "limit"
#> 
#> $paths$`/action/organization_list`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_list`$get$parameters[[2]]$description
#> [1] "The number of organizations to be returned per page"
#> 
#> $paths$`/action/organization_list`$get$parameters[[2]]$schema
#> $paths$`/action/organization_list`$get$parameters[[2]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/organization_list`$get$parameters[[2]]$schema$default
#> [1] 100
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_list`$get$tags
#> $paths$`/action/organization_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_list`$get$responses
#> $paths$`/action/organization_list`$get$responses$`200`
#> $paths$`/action/organization_list`$get$responses$`200`$description
#> [1] "List of organizations"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_autocomplete`
#> $paths$`/action/organization_autocomplete`$get
#> $paths$`/action/organization_autocomplete`$get$summary
#> [1] "Get names of organizations that match a query string"
#> 
#> $paths$`/action/organization_autocomplete`$get$description
#> [1] "Return a list of organization names that contain a string"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters
#> $paths$`/action/organization_autocomplete`$get$parameters[[1]]
#> $paths$`/action/organization_autocomplete`$get$parameters[[1]]$name
#> [1] "q"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[1]]$description
#> [1] "The string to search for"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[1]]$schema
#> $paths$`/action/organization_autocomplete`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[1]]$schema$default
#> [1] "ministry"
#> 
#> 
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[2]]
#> $paths$`/action/organization_autocomplete`$get$parameters[[2]]$name
#> [1] "limit"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[2]]$description
#> [1] "The maximum number of organizations to return (optional)"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[2]]$schema
#> $paths$`/action/organization_autocomplete`$get$parameters[[2]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters[[2]]$schema$default
#> [1] 20
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_autocomplete`$get$tags
#> $paths$`/action/organization_autocomplete`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/organization_autocomplete`$get$responses
#> $paths$`/action/organization_autocomplete`$get$responses$`200`
#> $paths$`/action/organization_autocomplete`$get$responses$`200`$description
#> [1] "List of organizations"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/resource_search`
#> $paths$`/action/resource_search`$get
#> $paths$`/action/resource_search`$get$summary
#> [1] "Find resources"
#> 
#> $paths$`/action/resource_search`$get$description
#> [1] "Returns a dictionary with two fields ``count`` and ``results``.             The ``count`` field contains the total number of Resources                found without the limit or query parameters having an effect.             The ``results`` field is a list of dictized Resource objects.             The query parameter is a required field. It is a string in                the form ``{field}:{term}`` or a list of strings, each of the             same form. Within each string, ``{field}`` is a field or extra             field on the Resource domain object."
#> 
#> $paths$`/action/resource_search`$get$parameters
#> $paths$`/action/resource_search`$get$parameters[[1]]
#> $paths$`/action/resource_search`$get$parameters[[1]]$name
#> [1] "query"
#> 
#> $paths$`/action/resource_search`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/resource_search`$get$parameters[[1]]$description
#> [1] "The search criteria string or list of strings of the form ``{field}:{term1}``"
#> 
#> $paths$`/action/resource_search`$get$parameters[[1]]$schema
#> $paths$`/action/resource_search`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/resource_search`$get$parameters[[1]]$schema$default
#> [1] "format:csv"
#> 
#> 
#> 
#> $paths$`/action/resource_search`$get$parameters[[2]]
#> $paths$`/action/resource_search`$get$parameters[[2]]$name
#> [1] "fields"
#> 
#> $paths$`/action/resource_search`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/resource_search`$get$parameters[[2]]$description
#> [1] "Depreciated"
#> 
#> $paths$`/action/resource_search`$get$parameters[[2]]$schema
#> $paths$`/action/resource_search`$get$parameters[[2]]$schema$type
#> [1] "string"
#> 
#> 
#> 
#> $paths$`/action/resource_search`$get$parameters[[3]]
#> $paths$`/action/resource_search`$get$parameters[[3]]$name
#> [1] "order_by"
#> 
#> $paths$`/action/resource_search`$get$parameters[[3]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/resource_search`$get$parameters[[3]]$description
#> [1] "A field on the resource model that orders the results"
#> 
#> $paths$`/action/resource_search`$get$parameters[[3]]$schema
#> $paths$`/action/resource_search`$get$parameters[[3]]$schema$type
#> [1] "string"
#> 
#> 
#> 
#> $paths$`/action/resource_search`$get$parameters[[4]]
#> $paths$`/action/resource_search`$get$parameters[[4]]$name
#> [1] "offset"
#> 
#> $paths$`/action/resource_search`$get$parameters[[4]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/resource_search`$get$parameters[[4]]$description
#> [1] "Apply an offset to the query"
#> 
#> $paths$`/action/resource_search`$get$parameters[[4]]$schema
#> $paths$`/action/resource_search`$get$parameters[[4]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/resource_search`$get$parameters[[4]]$schema$default
#> [1] 0
#> 
#> 
#> 
#> $paths$`/action/resource_search`$get$parameters[[5]]
#> $paths$`/action/resource_search`$get$parameters[[5]]$name
#> [1] "limit"
#> 
#> $paths$`/action/resource_search`$get$parameters[[5]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/resource_search`$get$parameters[[5]]$description
#> [1] "Apply a limit to the query"
#> 
#> $paths$`/action/resource_search`$get$parameters[[5]]$schema
#> $paths$`/action/resource_search`$get$parameters[[5]]$schema$type
#> [1] "integer"
#> 
#> $paths$`/action/resource_search`$get$parameters[[5]]$schema$default
#> [1] 0
#> 
#> 
#> 
#> 
#> $paths$`/action/resource_search`$get$tags
#> $paths$`/action/resource_search`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/resource_search`$get$responses
#> $paths$`/action/resource_search`$get$responses$`200`
#> $paths$`/action/resource_search`$get$responses$`200`$description
#> [1] "Search for resources"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/resource_show`
#> $paths$`/action/resource_show`$get
#> $paths$`/action/resource_show`$get$summary
#> [1] "Get metadata for a specific resource"
#> 
#> $paths$`/action/resource_show`$get$description
#> [1] "Return the metadata of a resource"
#> 
#> $paths$`/action/resource_show`$get$parameters
#> $paths$`/action/resource_show`$get$parameters[[1]]
#> $paths$`/action/resource_show`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/resource_show`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/resource_show`$get$parameters[[1]]$description
#> [1] "The id of the resource"
#> 
#> $paths$`/action/resource_show`$get$parameters[[1]]$schema
#> $paths$`/action/resource_show`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> $paths$`/action/resource_show`$get$parameters[[1]]$schema$default
#> [1] "e6c8bb1d-3726-418b-9b7e-1d97a9bbb817"
#> 
#> 
#> 
#> $paths$`/action/resource_show`$get$parameters[[2]]
#> $paths$`/action/resource_show`$get$parameters[[2]]$name
#> [1] "include_tracking"
#> 
#> $paths$`/action/resource_show`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/resource_show`$get$parameters[[2]]$description
#> [1] "Add tracking information to dataset"
#> 
#> $paths$`/action/resource_show`$get$parameters[[2]]$schema
#> $paths$`/action/resource_show`$get$parameters[[2]]$schema$type
#> [1] "boolean"
#> 
#> $paths$`/action/resource_show`$get$parameters[[2]]$schema$default
#> [1] FALSE
#> 
#> 
#> 
#> 
#> $paths$`/action/resource_show`$get$tags
#> $paths$`/action/resource_show`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/resource_show`$get$responses
#> $paths$`/action/resource_show`$get$responses$`200`
#> $paths$`/action/resource_show`$get$responses$`200`$description
#> [1] "Return metadata of a resource"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/related_list`
#> $paths$`/action/related_list`$get
#> $paths$`/action/related_list`$get$summary
#> [1] "Gets items related to a package (dataset)"
#> 
#> $paths$`/action/related_list`$get$description
#> [1] "Returns a dataset's related items."
#> 
#> $paths$`/action/related_list`$get$parameters
#> $paths$`/action/related_list`$get$parameters[[1]]
#> $paths$`/action/related_list`$get$parameters[[1]]$name
#> [1] "id"
#> 
#> $paths$`/action/related_list`$get$parameters[[1]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/related_list`$get$parameters[[1]]$description
#> [1] "id or name of the dataset (optional)"
#> 
#> $paths$`/action/related_list`$get$parameters[[1]]$schema
#> $paths$`/action/related_list`$get$parameters[[1]]$schema$type
#> [1] "string"
#> 
#> 
#> 
#> $paths$`/action/related_list`$get$parameters[[2]]
#> $paths$`/action/related_list`$get$parameters[[2]]$name
#> [1] "dataset"
#> 
#> $paths$`/action/related_list`$get$parameters[[2]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/related_list`$get$parameters[[2]]$description
#> [1] "Dataset dictionary of the dataset (optional)"
#> 
#> $paths$`/action/related_list`$get$parameters[[2]]$schema
#> $paths$`/action/related_list`$get$parameters[[2]]$schema$type
#> [1] "string"
#> 
#> 
#> 
#> $paths$`/action/related_list`$get$parameters[[3]]
#> $paths$`/action/related_list`$get$parameters[[3]]$name
#> [1] "type_filter"
#> 
#> $paths$`/action/related_list`$get$parameters[[3]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/related_list`$get$parameters[[3]]$description
#> [1] "The type of related item to show (optional)"
#> 
#> $paths$`/action/related_list`$get$parameters[[3]]$schema
#> $paths$`/action/related_list`$get$parameters[[3]]$schema$type
#> [1] "string"
#> 
#> 
#> 
#> $paths$`/action/related_list`$get$parameters[[4]]
#> $paths$`/action/related_list`$get$parameters[[4]]$name
#> [1] "sort"
#> 
#> $paths$`/action/related_list`$get$parameters[[4]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/related_list`$get$parameters[[4]]$description
#> [1] "The order to sort the related items in"
#> 
#> $paths$`/action/related_list`$get$parameters[[4]]$schema
#> $paths$`/action/related_list`$get$parameters[[4]]$schema$type
#> [1] "string"
#> 
#> 
#> 
#> $paths$`/action/related_list`$get$parameters[[5]]
#> $paths$`/action/related_list`$get$parameters[[5]]$name
#> [1] "featured"
#> 
#> $paths$`/action/related_list`$get$parameters[[5]]$`in`
#> [1] "query"
#> 
#> $paths$`/action/related_list`$get$parameters[[5]]$description
#> [1] "whether or not to restrict the results to only featured items"
#> 
#> $paths$`/action/related_list`$get$parameters[[5]]$schema
#> $paths$`/action/related_list`$get$parameters[[5]]$schema$type
#> [1] "string"
#> 
#> 
#> 
#> 
#> $paths$`/action/related_list`$get$tags
#> $paths$`/action/related_list`$get$tags[[1]]
#> [1] "action"
#> 
#> 
#> $paths$`/action/related_list`$get$responses
#> $paths$`/action/related_list`$get$responses$`200`
#> $paths$`/action/related_list`$get$responses$`200`$description
#> [1] "Search for related items"
#> 
#> 
#> 
#> 
#> 
#> 
#> $components
#> $components$schemas
#> named list()
#> 
#> $components$securitySchemes
#> $components$securitySchemes$githubAccessCode
#> $components$securitySchemes$githubAccessCode$type
#> [1] "oauth2"
#> 
#> $components$securitySchemes$githubAccessCode$flows
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$authorizationUrl
#> [1] "https://github.com/login/oauth/authorize"
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$tokenUrl
#> [1] "https://github.com/login/oauth/access_token"
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$user
#> [1] "Grants read/write access to profile info only. Note that this scope includes user:email and user:follow."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`user:email`
#> [1] "Grants read access to a user's email addresses."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`user:follow`
#> [1] "Grants access to follow or unfollow other users."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$public_repo
#> [1] "Grants read/write access to code, commit statuses, and deployment statuses for public repositories and organizations."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$repo
#> [1] "Grants read/write access to code, commit statuses, and deployment statuses for public and private repositories and organizations."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$repo_deployment
#> [1] "Grants access to deployment statuses for public and private repositories. This scope is only necessary to grant other users or services access to deployment statuses, without granting access to the code."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`repo:status`
#> [1] "Grants read/write access to public and private repository commit statuses. This scope is only necessary to grant other users or services access to private repository commit statuses without granting access to the code."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$delete_repo
#> [1] "Grants access to delete adminable repositories."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$notifications
#> [1] "Grants read access to a user's notifications. repo also provides this access."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$gist
#> [1] "Grants write access to gists."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`read:repo_hook`
#> [1] "Grants read and ping access to hooks in public or private repositories."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`write:repo_hook`
#> [1] "Grants read, write, and ping access to hooks in public or private repositories."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`admin:repo_hook`
#> [1] "Grants read, write, ping, and delete access to hooks in public or private repositories."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`read:org`
#> [1] "Read-only access to organization, teams, and membership."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`write:org`
#> [1] "Publicize and unpublicize organization membership."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`admin:org`
#> [1] "Fully manage organization, teams, and memberships."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`read:public_key`
#> [1] "List and view details for public keys."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`write:public_key`
#> [1] "Create, list, and view details for public keys."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`admin:public_key`
#> [1] "Fully manage public keys."
#> 
#> 
#> 
#> 
#> 
#> $components$securitySchemes$internalApiKey
#> $components$securitySchemes$internalApiKey$type
#> [1] "apiKey"
#> 
#> $components$securitySchemes$internalApiKey$`in`
#> [1] "header"
#> 
#> $components$securitySchemes$internalApiKey$name
#> [1] "ckan_api_key"
#> 
#> 
#> 
#> 

## we can control some properties of the list object returned by
## jsonlite::read_json by setting simplifyVector = TRUE or
## simplifyDataframe = TRUE
try(
 bcdc_get_data(record = "a2a2130b-e853-49e8-9b30-1d0c735aa3d9",
                resource = "0b9e7d31-91ff-4146-a473-106a3b301964",
                simplifyVector = TRUE)
)
#> Reading the data using the read_json function from the jsonlite package.
#> $openapi
#> [1] "3.0.0"
#> 
#> $servers
#>                                      url description
#> 1 https://catalogue.data.gov.bc.ca/api/3  Production
#> 2       https://cat.data.gov.bc.ca/api/3        Test
#> 3       https://cad.data.gov.bc.ca/api/3    Delivery
#> 
#> $info
#> $info$title
#> [1] "BC Data Catalogue API"
#> 
#> $info$description
#> [1] "This API provides live access to the BC Data Catalogue. Further documentation on the API is available from http://docs.ckan.org/en/latest/ Confirm the version of the API available from the catalogue by requesting https://catalogue.data.gov.bc.ca/api/3/action/status_show. \n\nPlease note that you may experience issues when submitting requests to the delivery or test environment if using this [OpenAPI specification](https://github.com/bcgov/api-specs) in other API console viewers."
#> 
#> $info$termsOfService
#> [1] "https://www2.gov.bc.ca/gov/content?id=D1EE0A405E584363B205CD4353E02C88"
#> 
#> $info$contact
#> $info$contact$name
#> [1] "Data BC"
#> 
#> $info$contact$url
#> [1] "http://data.gov.bc.ca/"
#> 
#> $info$contact$email
#> [1] "data@gov.bc.ca"
#> 
#> 
#> $info$license
#> $info$license$name
#> [1] "Open Government License - British Columbia"
#> 
#> $info$license$url
#> [1] "https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61"
#> 
#> 
#> $info$version
#> [1] "3.0.1"
#> 
#> 
#> $tags
#>     name
#> 1 action
#>                                                                                               description
#> 1 CKAN's Action API is a powerful, RPC-style API that exposes all of CKAN's core features to API clients.
#>   externalDocs.description
#> 1            Find out more
#>                                    externalDocs.url
#> 1 http://docs.ckan.org/en/ckan-2.5.3/api/index.html
#> 
#> $security
#>                                                                                                                                                                                                                                          githubAccessCode
#> 1 user, user:email, user:follow, public_repo, repo, repo_deployment, repo:status, delete_repo, notifications, gist, read:repo_hook, write:repo_hook, admin:repo_hook, read:org, write:org, admin:org, read:public_key, write:public_key, admin:public_key
#> 2                                                                                                                                                                                                                                                    NULL
#>   internalApiKey
#> 1           NULL
#> 2           NULL
#> 
#> $paths
#> $paths$`/action/tag_list`
#> $paths$`/action/tag_list`$get
#> $paths$`/action/tag_list`$get$summary
#> [1] "Get a list of tags"
#> 
#> $paths$`/action/tag_list`$get$description
#> [1] "Returns the names of all indexed tags"
#> 
#> $paths$`/action/tag_list`$get$parameters
#>     name    in
#> 1 offset query
#> 2  limit query
#>                                     description schema.type
#> 1 The offset (index) of the first tag to return     integer
#> 2    The number of tags to be returned per page     integer
#>   schema.default
#> 1              0
#> 2            100
#> 
#> $paths$`/action/tag_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/tag_list`$get$responses
#> $paths$`/action/tag_list`$get$responses$`200`
#> $paths$`/action/tag_list`$get$responses$`200`$description
#> [1] "List of tags"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/status_show`
#> $paths$`/action/status_show`$get
#> $paths$`/action/status_show`$get$summary
#> [1] "Get the site status"
#> 
#> $paths$`/action/status_show`$get$description
#> [1] "Returns the site status"
#> 
#> $paths$`/action/status_show`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/status_show`$get$responses
#> $paths$`/action/status_show`$get$responses$`200`
#> $paths$`/action/status_show`$get$responses$`200`$description
#> [1] "Returns the site status, version, installed extensions"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_list`
#> $paths$`/action/package_list`$get
#> $paths$`/action/package_list`$get$summary
#> [1] "Get a list of all packages (datasets)"
#> 
#> $paths$`/action/package_list`$get$description
#> [1] "Returns the names of all indexed packages (datasets)"
#> 
#> $paths$`/action/package_list`$get$parameters
#>     name    in
#> 1 offset query
#> 2  limit query
#>                                         description
#> 1 The offset (index) of the first package to return
#> 2    The number of packages to be returned per page
#>   schema.type schema.default
#> 1     integer              0
#> 2     integer            100
#> 
#> $paths$`/action/package_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/package_list`$get$responses
#> $paths$`/action/package_list`$get$responses$`200`
#> $paths$`/action/package_list`$get$responses$`200`$description
#> [1] "List of packages"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_search`
#> $paths$`/action/package_search`$get
#> $paths$`/action/package_search`$get$summary
#> [1] "Find packages (datasets) matching query terms"
#> 
#> $paths$`/action/package_search`$get$description
#> [1] "Searches for packages (datasets) matching the specified query terms"
#> 
#> $paths$`/action/package_search`$get$parameters
#>   name    in    description schema.type  schema.default
#> 1    q query A query string      string "Okanagan Lake"
#> 
#> $paths$`/action/package_search`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/package_search`$get$responses
#> $paths$`/action/package_search`$get$responses$`200`
#> $paths$`/action/package_search`$get$responses$`200`$description
#> [1] "List of packages"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_show`
#> $paths$`/action/package_show`$get
#> $paths$`/action/package_show`$get$summary
#> [1] "Get metadata about one specific package (dataset)"
#> 
#> $paths$`/action/package_show`$get$description
#> [1] "Returns metadata about the package (dataset) corresponding to the specified unique name"
#> 
#> $paths$`/action/package_show`$get$parameters
#>   name    in      description schema.type
#> 1   id query The package name      string
#>                  schema.default
#> 1 grizzly-bear-population-units
#> 
#> $paths$`/action/package_show`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/package_show`$get$responses
#> $paths$`/action/package_show`$get$responses$`200`
#> $paths$`/action/package_show`$get$responses$`200`$description
#> [1] "A package metadata object"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_activity_list`
#> $paths$`/action/package_activity_list`$get
#> $paths$`/action/package_activity_list`$get$summary
#> [1] "Get the activity stream of a package (dataset)"
#> 
#> $paths$`/action/package_activity_list`$get$description
#> [1] "Returns a package's activity stream"
#> 
#> $paths$`/action/package_activity_list`$get$parameters
#>     name    in                                description
#> 1     id query              The id or name of the package
#> 2 offset query Where to start getting activity items from
#> 3  limit query The maximum number of activities to return
#>   schema.type                schema.default
#> 1      string grizzly-bear-population-units
#> 2     integer                             0
#> 3     integer                            31
#> 
#> $paths$`/action/package_activity_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/package_activity_list`$get$responses
#> $paths$`/action/package_activity_list`$get$responses$`200`
#> $paths$`/action/package_activity_list`$get$responses$`200`$description
#> [1] "List of activities"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_activity_list_html`
#> $paths$`/action/package_activity_list_html`$get
#> $paths$`/action/package_activity_list_html`$get$summary
#> [1] "Get the activity stream of a package (dataset), HTML format"
#> 
#> $paths$`/action/package_activity_list_html`$get$description
#> [1] "The activity stream is rendered as a snippet of HTML meant to be included in an HTML pag, i.e it doesn't have any header or footer."
#> 
#> $paths$`/action/package_activity_list_html`$get$parameters
#>     name    in                                description
#> 1     id query              The id or name of the package
#> 2 offset query Where to start getting activity items from
#> 3  limit query The maximum number of activities to return
#>   schema.type                schema.default
#> 1      string grizzly-bear-population-units
#> 2     integer                             0
#> 3     integer                            31
#> 
#> $paths$`/action/package_activity_list_html`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/package_activity_list_html`$get$responses
#> $paths$`/action/package_activity_list_html`$get$responses$`200`
#> $paths$`/action/package_activity_list_html`$get$responses$`200`$description
#> [1] "List of activities rendered as HTML snippet"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_autocomplete`
#> $paths$`/action/package_autocomplete`$get
#> $paths$`/action/package_autocomplete`$get$summary
#> [1] "Find packages (datasets) matching a query"
#> 
#> $paths$`/action/package_autocomplete`$get$description
#> [1] "Return a list of datasets that match a string"
#> 
#> $paths$`/action/package_autocomplete`$get$parameters
#>    name    in
#> 1     q query
#> 2 limit query
#>                                        description
#> 1                              The string to query
#> 2 The maximum number of resource formats to return
#>   schema.type  schema.default
#> 1      string "Okanagan Lake"
#> 2     integer              10
#> 
#> $paths$`/action/package_autocomplete`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/package_autocomplete`$get$responses
#> $paths$`/action/package_autocomplete`$get$responses$`200`
#> $paths$`/action/package_autocomplete`$get$responses$`200`$description
#> [1] "List of datasets that match a string"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_relationships_list`
#> $paths$`/action/package_relationships_list`$get
#> $paths$`/action/package_relationships_list`$get$summary
#> [1] "Get package (dataset) relationships"
#> 
#> $paths$`/action/package_relationships_list`$get$description
#> [1] "Return a dataset's relationships"
#> 
#> $paths$`/action/package_relationships_list`$get$parameters
#>   name    in                          description
#> 1   id query  The id or name of the first package
#> 2  id2 query The id or name of the second package
#> 3  rel query               relationship as string
#>   schema.type                schema.default
#> 1      string grizzly-bear-population-units
#> 2      string        important-fossil-areas
#> 3      string                          <NA>
#> 
#> $paths$`/action/package_relationships_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/package_relationships_list`$get$responses
#> $paths$`/action/package_relationships_list`$get$responses$`200`
#> $paths$`/action/package_relationships_list`$get$responses$`200`$description
#> [1] "List of dataset relationships"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/package_revision_list`
#> $paths$`/action/package_revision_list`$get
#> $paths$`/action/package_revision_list`$get$summary
#> [1] "Get list of revisions for a package (dataset)"
#> 
#> $paths$`/action/package_revision_list`$get$description
#> [1] "Return a dataset's revision as a list of dictionaries"
#> 
#> $paths$`/action/package_revision_list`$get$parameters
#>   name    in                   description schema.type
#> 1   id query The id or name of the dataset      string
#>                  schema.default
#> 1 grizzly-bear-population-units
#> 
#> $paths$`/action/package_revision_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/package_revision_list`$get$responses
#> $paths$`/action/package_revision_list`$get$responses$`200`
#> $paths$`/action/package_revision_list`$get$responses$`200`$description
#> [1] "List of dataset revisions"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_activity_list`
#> $paths$`/action/organization_activity_list`$get
#> $paths$`/action/organization_activity_list`$get$summary
#> [1] "Get the activity stream of an organization"
#> 
#> $paths$`/action/organization_activity_list`$get$description
#> [1] "Return an organization's activity stream"
#> 
#> $paths$`/action/organization_activity_list`$get$parameters
#>   name    in                        description schema.type
#> 1   id query The id or name of the organization      string
#>            schema.default
#> 1 ministry-of-agriculture
#> 
#> $paths$`/action/organization_activity_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_activity_list`$get$responses
#> $paths$`/action/organization_activity_list`$get$responses$`200`
#> $paths$`/action/organization_activity_list`$get$responses$`200`$description
#> [1] "List of an organization's activities"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_activity_list_html`
#> $paths$`/action/organization_activity_list_html`$get
#> $paths$`/action/organization_activity_list_html`$get$summary
#> [1] "Get the activity stream of an organization, HTML format"
#> 
#> $paths$`/action/organization_activity_list_html`$get$description
#> [1] "Return an organization's activity stream as HTML"
#> 
#> $paths$`/action/organization_activity_list_html`$get$parameters
#>   name    in                        description schema.type
#> 1   id query The id or name of the organization      string
#>            schema.default
#> 1 ministry-of-agriculture
#> 
#> $paths$`/action/organization_activity_list_html`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_activity_list_html`$get$responses
#> $paths$`/action/organization_activity_list_html`$get$responses$`200`
#> $paths$`/action/organization_activity_list_html`$get$responses$`200`$description
#> [1] "List of an organization's activities in HTML"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_follower_count`
#> $paths$`/action/organization_follower_count`$get
#> $paths$`/action/organization_follower_count`$get$summary
#> [1] "Get number of followers of an organization"
#> 
#> $paths$`/action/organization_follower_count`$get$description
#> [1] "Return the number of followers of an organization"
#> 
#> $paths$`/action/organization_follower_count`$get$parameters
#>   name    in                        description schema.type
#> 1   id query The id or name of the organization      string
#>            schema.default
#> 1 ministry-of-agriculture
#> 
#> $paths$`/action/organization_follower_count`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_follower_count`$get$responses
#> $paths$`/action/organization_follower_count`$get$responses$`200`
#> $paths$`/action/organization_follower_count`$get$responses$`200`$description
#> [1] "Count of organization followers"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_follower_list`
#> $paths$`/action/organization_follower_list`$get
#> $paths$`/action/organization_follower_list`$get$summary
#> [1] "Get users following an organization"
#> 
#> $paths$`/action/organization_follower_list`$get$description
#> [1] "Return a list of users that are following a given organization"
#> 
#> $paths$`/action/organization_follower_list`$get$parameters
#>   name    in                        description schema.type
#> 1   id query The id or name of the organization      string
#>            schema.default
#> 1 ministry-of-agriculture
#> 
#> $paths$`/action/organization_follower_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_follower_list`$get$responses
#> $paths$`/action/organization_follower_list`$get$responses$`200`
#> $paths$`/action/organization_follower_list`$get$responses$`200`$description
#> [1] "List of organization followers"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_list_for_user`
#> $paths$`/action/organization_list_for_user`$get
#> $paths$`/action/organization_list_for_user`$get$summary
#> [1] "Get organizations that a user has a given permission for"
#> 
#> $paths$`/action/organization_list_for_user`$get$description
#> [1] "Return the organizations that the user has a given permission for"
#> 
#> $paths$`/action/organization_list_for_user`$get$parameters
#>         name    in
#> 1 permission query
#>                                                     description
#> 1 The permission the user has against the returned organization
#>   schema.type schema.default
#> 1      string   "edit_group"
#> 
#> $paths$`/action/organization_list_for_user`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_list_for_user`$get$responses
#> $paths$`/action/organization_list_for_user`$get$responses$`200`
#> $paths$`/action/organization_list_for_user`$get$responses$`200`$description
#> [1] "List of organizations for given permission"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_revision_list`
#> $paths$`/action/organization_revision_list`$get
#> $paths$`/action/organization_revision_list`$get$summary
#> [1] "Get organization revisions"
#> 
#> $paths$`/action/organization_revision_list`$get$description
#> [1] "Return an organization's revisions"
#> 
#> $paths$`/action/organization_revision_list`$get$parameters
#>   name    in                        description schema.type
#> 1   id query The name or id of the organization      string
#>            schema.default
#> 1 ministry-of-agriculture
#> 
#> $paths$`/action/organization_revision_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_revision_list`$get$responses
#> $paths$`/action/organization_revision_list`$get$responses$`200`
#> $paths$`/action/organization_revision_list`$get$responses$`200`$description
#> [1] "List of an organization's revisions"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_show`
#> $paths$`/action/organization_show`$get
#> $paths$`/action/organization_show`$get$summary
#> [1] "Get details of a specific organization"
#> 
#> $paths$`/action/organization_show`$get$description
#> [1] "Return the details of an organization"
#> 
#> $paths$`/action/organization_show`$get$parameters
#>               name    in
#> 1               id query
#> 2 include_datasets query
#>                                     description schema.type
#> 1            The id or name of the organization      string
#> 2 include a list of the organization's datasets     boolean
#>            schema.default
#> 1 ministry-of-agriculture
#> 2                    TRUE
#> 
#> $paths$`/action/organization_show`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_show`$get$responses
#> $paths$`/action/organization_show`$get$responses$`200`
#> $paths$`/action/organization_show`$get$responses$`200`$description
#> [1] "List organization details"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_list`
#> $paths$`/action/organization_list`$get
#> $paths$`/action/organization_list`$get$summary
#> [1] "Get names of all organizations"
#> 
#> $paths$`/action/organization_list`$get$description
#> [1] "Returns the names of all indexed organizations"
#> 
#> $paths$`/action/organization_list`$get$parameters
#>     name    in
#> 1 offset query
#> 2  limit query
#>                                               description
#> 1 The offset (index) of the first organizations to return
#> 2     The number of organizations to be returned per page
#>   schema.type schema.default
#> 1     integer              0
#> 2     integer            100
#> 
#> $paths$`/action/organization_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_list`$get$responses
#> $paths$`/action/organization_list`$get$responses$`200`
#> $paths$`/action/organization_list`$get$responses$`200`$description
#> [1] "List of organizations"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/organization_autocomplete`
#> $paths$`/action/organization_autocomplete`$get
#> $paths$`/action/organization_autocomplete`$get$summary
#> [1] "Get names of organizations that match a query string"
#> 
#> $paths$`/action/organization_autocomplete`$get$description
#> [1] "Return a list of organization names that contain a string"
#> 
#> $paths$`/action/organization_autocomplete`$get$parameters
#>    name    in
#> 1     q query
#> 2 limit query
#>                                                description
#> 1                                 The string to search for
#> 2 The maximum number of organizations to return (optional)
#>   schema.type schema.default
#> 1      string       ministry
#> 2     integer             20
#> 
#> $paths$`/action/organization_autocomplete`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/organization_autocomplete`$get$responses
#> $paths$`/action/organization_autocomplete`$get$responses$`200`
#> $paths$`/action/organization_autocomplete`$get$responses$`200`$description
#> [1] "List of organizations"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/resource_search`
#> $paths$`/action/resource_search`$get
#> $paths$`/action/resource_search`$get$summary
#> [1] "Find resources"
#> 
#> $paths$`/action/resource_search`$get$description
#> [1] "Returns a dictionary with two fields ``count`` and ``results``.             The ``count`` field contains the total number of Resources                found without the limit or query parameters having an effect.             The ``results`` field is a list of dictized Resource objects.             The query parameter is a required field. It is a string in                the form ``{field}:{term}`` or a list of strings, each of the             same form. Within each string, ``{field}`` is a field or extra             field on the Resource domain object."
#> 
#> $paths$`/action/resource_search`$get$parameters
#>       name    in
#> 1    query query
#> 2   fields query
#> 3 order_by query
#> 4   offset query
#> 5    limit query
#>                                                                     description
#> 1 The search criteria string or list of strings of the form ``{field}:{term1}``
#> 2                                                                   Depreciated
#> 3                         A field on the resource model that orders the results
#> 4                                                  Apply an offset to the query
#> 5                                                    Apply a limit to the query
#>   schema.type schema.default
#> 1      string     format:csv
#> 2      string           <NA>
#> 3      string           <NA>
#> 4     integer              0
#> 5     integer              0
#> 
#> $paths$`/action/resource_search`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/resource_search`$get$responses
#> $paths$`/action/resource_search`$get$responses$`200`
#> $paths$`/action/resource_search`$get$responses$`200`$description
#> [1] "Search for resources"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/resource_show`
#> $paths$`/action/resource_show`$get
#> $paths$`/action/resource_show`$get$summary
#> [1] "Get metadata for a specific resource"
#> 
#> $paths$`/action/resource_show`$get$description
#> [1] "Return the metadata of a resource"
#> 
#> $paths$`/action/resource_show`$get$parameters
#>               name    in
#> 1               id query
#> 2 include_tracking query
#>                           description schema.type
#> 1              The id of the resource      string
#> 2 Add tracking information to dataset     boolean
#>                         schema.default
#> 1 e6c8bb1d-3726-418b-9b7e-1d97a9bbb817
#> 2                                FALSE
#> 
#> $paths$`/action/resource_show`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/resource_show`$get$responses
#> $paths$`/action/resource_show`$get$responses$`200`
#> $paths$`/action/resource_show`$get$responses$`200`$description
#> [1] "Return metadata of a resource"
#> 
#> 
#> 
#> 
#> 
#> $paths$`/action/related_list`
#> $paths$`/action/related_list`$get
#> $paths$`/action/related_list`$get$summary
#> [1] "Gets items related to a package (dataset)"
#> 
#> $paths$`/action/related_list`$get$description
#> [1] "Returns a dataset's related items."
#> 
#> $paths$`/action/related_list`$get$parameters
#>          name    in
#> 1          id query
#> 2     dataset query
#> 3 type_filter query
#> 4        sort query
#> 5    featured query
#>                                                     description
#> 1                          id or name of the dataset (optional)
#> 2                  Dataset dictionary of the dataset (optional)
#> 3                   The type of related item to show (optional)
#> 4                        The order to sort the related items in
#> 5 whether or not to restrict the results to only featured items
#>     type
#> 1 string
#> 2 string
#> 3 string
#> 4 string
#> 5 string
#> 
#> $paths$`/action/related_list`$get$tags
#> [1] "action"
#> 
#> $paths$`/action/related_list`$get$responses
#> $paths$`/action/related_list`$get$responses$`200`
#> $paths$`/action/related_list`$get$responses$`200`$description
#> [1] "Search for related items"
#> 
#> 
#> 
#> 
#> 
#> 
#> $components
#> $components$schemas
#> named list()
#> 
#> $components$securitySchemes
#> $components$securitySchemes$githubAccessCode
#> $components$securitySchemes$githubAccessCode$type
#> [1] "oauth2"
#> 
#> $components$securitySchemes$githubAccessCode$flows
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$authorizationUrl
#> [1] "https://github.com/login/oauth/authorize"
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$tokenUrl
#> [1] "https://github.com/login/oauth/access_token"
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$user
#> [1] "Grants read/write access to profile info only. Note that this scope includes user:email and user:follow."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`user:email`
#> [1] "Grants read access to a user's email addresses."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`user:follow`
#> [1] "Grants access to follow or unfollow other users."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$public_repo
#> [1] "Grants read/write access to code, commit statuses, and deployment statuses for public repositories and organizations."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$repo
#> [1] "Grants read/write access to code, commit statuses, and deployment statuses for public and private repositories and organizations."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$repo_deployment
#> [1] "Grants access to deployment statuses for public and private repositories. This scope is only necessary to grant other users or services access to deployment statuses, without granting access to the code."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`repo:status`
#> [1] "Grants read/write access to public and private repository commit statuses. This scope is only necessary to grant other users or services access to private repository commit statuses without granting access to the code."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$delete_repo
#> [1] "Grants access to delete adminable repositories."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$notifications
#> [1] "Grants read access to a user's notifications. repo also provides this access."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$gist
#> [1] "Grants write access to gists."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`read:repo_hook`
#> [1] "Grants read and ping access to hooks in public or private repositories."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`write:repo_hook`
#> [1] "Grants read, write, and ping access to hooks in public or private repositories."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`admin:repo_hook`
#> [1] "Grants read, write, ping, and delete access to hooks in public or private repositories."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`read:org`
#> [1] "Read-only access to organization, teams, and membership."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`write:org`
#> [1] "Publicize and unpublicize organization membership."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`admin:org`
#> [1] "Fully manage organization, teams, and memberships."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`read:public_key`
#> [1] "List and view details for public keys."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`write:public_key`
#> [1] "Create, list, and view details for public keys."
#> 
#> $components$securitySchemes$githubAccessCode$flows$authorizationCode$scopes$`admin:public_key`
#> [1] "Fully manage public keys."
#> 
#> 
#> 
#> 
#> 
#> $components$securitySchemes$internalApiKey
#> $components$securitySchemes$internalApiKey$type
#> [1] "apiKey"
#> 
#> $components$securitySchemes$internalApiKey$`in`
#> [1] "header"
#> 
#> $components$securitySchemes$internalApiKey$name
#> [1] "ckan_api_key"
#> 
#> 
#> 
#> 
```
