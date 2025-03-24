# Issues:
#   https://github.com/bcgov/bcdata/issues/159
#   https://github.com/r-spatial/sf/issues/1219

library(sf)
library(httr)

mp_sfc <- sf::st_as_sfc("MULTIPOINT ((1236285 463726.8), (1228264 463547.4))")
mp_sfc

mp <- sf::st_as_text(mp_sfc)
mp # inner parentheses removed

format_multipoint <- function(x) {
  gsub("(-?[0-9.]+\\s+-?[0-9.]+)(,?)", "(\\1)\\2", x)
}

mp2 <- format_multipoint(mp)
mp2 # inner parentheses added

# Issue a request to geoserver using the multipoint without parentheses around
# points
a <- GET(
  "https://openmaps.gov.bc.ca/geo/pub/wfs",
  query = list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = "WHSE_BASEMAPPING.GBA_LOCAL_REG_GREENSPACES_SP",
    SRSNAME = "EPSG:3005",
    CQL_FILTER = paste0("INTERSECTS(SHAPE, ", mp, ")")
  )
)

URLdecode(a$url)
a$status_code
content(a, as = "text")

# Issue a request to geoserver using the multipoint *with* parentheses around
# points
b <- httr::GET(
  "https://openmaps.gov.bc.ca/geo/pub/wfs",
  query = list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = "WHSE_BASEMAPPING.GBA_LOCAL_REG_GREENSPACES_SP",
    SRSNAME = "EPSG:3005",
    CQL_FILTER = paste0("INTERSECTS(SHAPE, ", mp2, ")")
  )
)

URLdecode(b$url)
b$status_code
b_content <- content(b, as = "text")
read_sf(b_content)

## Check speed with biggish data set
# wells <- bcdc_query_geodata("bc-environmental-monitoring-locations") %>% collect()
# saveRDS(wells, "wells.rds")
wells <- readRDS("wells.rds") %>%
  st_geometry() %>%
  st_combine()

wells_4326 <- st_transform(wells, 4326)

tictoc::tic()
mp_text <- st_as_text(wells)
tictoc::toc()
tictoc::tic()
mp_formatted <- format_multipoint(mp_text)
tictoc::toc()

# Decimal degrees, with negative signs
mp_text <- st_as_text(wells_4326)
mp_formatted <- format_multipoint(mp_text)
substr(mp_formatted, 1, 500)
