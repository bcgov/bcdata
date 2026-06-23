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
#> B.C. Data Catalogue Record: BC
#>  Airports
#> Name: bc-airports (ID:
#>  76b1b7a3-2112-4444-857a-afccf7b20da8)
#> Permalink:
#>  https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8
#> Licence: Open Government Licence -
#>  British Columbia
#> Description: BC Airports identifies
#>  locations where aircraft may take-off and land. No
#>  guarantee is given that an identified point will be
#>  maintained to sufficient standards for landing and
#>  take-off of any/all aircraft.  It includes airports,
#>  aerodromes, water aerodromes, heliports, and
#>  airstrips.
#> Available Resources (2):
#>  1. BC_Airports_Attribute_Values (xlsx)
#>  2. WMS getCapabilities request (wms)
#> Access the full 'Resources' data frame using:
#>  bcdc_tidy_resources('76b1b7a3-2112-4444-857a-afccf7b20da8')
#> Query and filter this data using:
#>  bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8')

try(
  bcdc_get_record("bc-airports")
)
#> B.C. Data Catalogue Record: BC
#>  Airports
#> Name: bc-airports (ID:
#>  76b1b7a3-2112-4444-857a-afccf7b20da8)
#> Permalink:
#>  https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8
#> Licence: Open Government Licence -
#>  British Columbia
#> Description: BC Airports identifies
#>  locations where aircraft may take-off and land. No
#>  guarantee is given that an identified point will be
#>  maintained to sufficient standards for landing and
#>  take-off of any/all aircraft.  It includes airports,
#>  aerodromes, water aerodromes, heliports, and
#>  airstrips.
#> Available Resources (2):
#>  1. BC_Airports_Attribute_Values (xlsx)
#>  2. WMS getCapabilities request (wms)
#> Access the full 'Resources' data frame using:
#>  bcdc_tidy_resources('76b1b7a3-2112-4444-857a-afccf7b20da8')
#> Query and filter this data using:
#>  bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8')

try(
  bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8")
)
#> B.C. Data Catalogue Record: BC
#>  Airports
#> Name: bc-airports (ID:
#>  76b1b7a3-2112-4444-857a-afccf7b20da8)
#> Permalink:
#>  https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8
#> Licence: Open Government Licence -
#>  British Columbia
#> Description: BC Airports identifies
#>  locations where aircraft may take-off and land. No
#>  guarantee is given that an identified point will be
#>  maintained to sufficient standards for landing and
#>  take-off of any/all aircraft.  It includes airports,
#>  aerodromes, water aerodromes, heliports, and
#>  airstrips.
#> Available Resources (2):
#>  1. BC_Airports_Attribute_Values (xlsx)
#>  2. WMS getCapabilities request (wms)
#> Access the full 'Resources' data frame using:
#>  bcdc_tidy_resources('76b1b7a3-2112-4444-857a-afccf7b20da8')
#> Query and filter this data using:
#>  bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8')

try(
  bcdc_get_record("76b1b7a3-2112-4444-857a-afccf7b20da8")
)
#> B.C. Data Catalogue Record: BC
#>  Airports
#> Name: bc-airports (ID:
#>  76b1b7a3-2112-4444-857a-afccf7b20da8)
#> Permalink:
#>  https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8
#> Licence: Open Government Licence -
#>  British Columbia
#> Description: BC Airports identifies
#>  locations where aircraft may take-off and land. No
#>  guarantee is given that an identified point will be
#>  maintained to sufficient standards for landing and
#>  take-off of any/all aircraft.  It includes airports,
#>  aerodromes, water aerodromes, heliports, and
#>  airstrips.
#> Available Resources (2):
#>  1. BC_Airports_Attribute_Values (xlsx)
#>  2. WMS getCapabilities request (wms)
#> Access the full 'Resources' data frame using:
#>  bcdc_tidy_resources('76b1b7a3-2112-4444-857a-afccf7b20da8')
#> Query and filter this data using:
#>  bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8')
# }
```
