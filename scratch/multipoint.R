
format_multipoint <- function(x) {
  x <- gsub("(\\(\\d+(\\.)?\\d*)", "(\\1", x)
  x <- gsub("(\\d+),\\s*", "\\1), (", x)
  gsub("(\\))$", "\\1)", x)
}

format_wkt("MULTIPOINT (1164434 368738.7, 1203024 412959)")
format_wkt("POINT (1164434 368738.7)")
format_wkt("MULTIPOINT (1164434 368738.7, 1203024 412959, 1203025 412960)")
format_wkt("MULTIPOINT (1164434 368738.7 20, 1203024 412959 50, 1203025 412960 100)")

sf::st_as_text(sf::st_as_sfc("MULTIPOINT ((1236285 463726.8), (1228264 463547.4))"))

httr::GET("https://openmaps.gov.bc.ca/geo/pub/wfs",
          query = list(
            SERVICE = "WFS",
            VERSION = "2.0.0",
            REQUEST = "GetFeature",
            outputFormat = "application/json",
            typeNames = "WHSE_BASEMAPPING.GBA_LOCAL_REG_GREENSPACES_SP",
            SRSNAME = "EPSG:3005",
            CQL_FILTER = "(INTERSECTS(SHAPE, MULTIPOINT (1236285 463726.8, 1228264 463547.4)))"
          ))

foo <- httr::GET("https://openmaps.gov.bc.ca/geo/pub/wfs",
          query = list(
            SERVICE = "WFS",
            VERSION = "2.0.0",
            REQUEST = "GetFeature",
            outputFormat = "application/json",
            typeNames = "WHSE_BASEMAPPING.GBA_LOCAL_REG_GREENSPACES_SP",
            SRSNAME = "EPSG:3005",
            CQL_FILTER = "(INTERSECTS(SHAPE, MULTIPOINT ((1236285 463726.8), (1228264 463547.4))))"
          ))

httr::content(foo)
