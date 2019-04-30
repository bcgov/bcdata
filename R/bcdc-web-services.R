# Copyright 2018 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


#' Get data from the BC Web Feature Service (DEPRECATED)
#'
#'
#' @inheritParams bcdc_get_data
#' @param crs the epsg code for the coordinate reference system. Defaults to `3005`
#'        (B.C. Albers). See https://epsgi.io.
#'
#' @return an `sf` object
#'
#' @export
#'
bcdc_get_geodata <- function(x = NULL, crs = 3005) {
  message("bcdc_get_geodata is defunct in favour of bcdc_get_data")
  message("You can use the same argument to pull spatial data from the BC Data Catalogue:")
  message(glue::glue("    bcdc_get_data('{x}')"))

}

#' Query data from the BC Web Feature Service
#'
#' Queries features from the BC Web Feature Service. The data must be available as
#' a wms/wfs service. See `bcdc_get_record(x)$resources`). Pulls features off the web. The data must be available as a wms/wfs service.
#' See `bcdc_get_record(x)$resources`). If the record is greater than 10000 rows,
#' the response will be paginated. If you are querying layers of this size, expect
#' that the request will take quite a while.
#'
#' @inheritParams bcdc_get_data
#' @param crs the epsg code for the coordinate reference system. Defaults to `3005`
#'        (B.C. Albers). See https://epsgi.io.
#'
#' @return an `sf` object
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' bcdc_query_geodata("bc-airports", crs = 3857)
#' bcdc_query_geodata("bc-airports", crs = 3857) %>%
#'   filter(PHYSICAL_ADDRESS == 'Victoria, BC') %>%
#'   collect()
#' bcdc_query_geodata("ground-water-wells") %>%
#'   filter(OBSERVATION_WELL_NUMBER == 108)
#'
#' ## A moderately large layer

#' bcdc_query_geodata("bc-environmental-monitoring-locations")
#' bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
#'   filter(PERMIT_RELATIONSHIP == "DISCHARGE")
#'
#'
#' ## A very large layer
#' bcdc_query_geodata("terrestrial-protected-areas-representation-by-biogeoclimatic-unit")
#' }
#'
bcdc_query_geodata <- function(x = NULL, crs = 3005) {
  obj <- bcdc_get_record(x)
  if (!"wms" %in% vapply(obj$resources, `[[`, "format", FUN.VALUE = character(1))) {
    stop("No wms/wfs resource available for this dataset.",
         call. = FALSE
    )
  }

  ## Parameters for the API call
  query_list <- list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = obj$layer_name,
    SRSNAME = paste0("EPSG:", crs)
  )

  ## Drop any NULLS from the list
  query_list <- compact(query_list)

  ## GET and parse data to sf object
  cli <- bcdc_http_client(url = "https://openmaps.gov.bc.ca/geo/pub/wfs")

  as.bcdc_promise(list(query_list = query_list, cli = cli, obj = obj))

}

#' Get map from the BC Web Mapping Service
#'
#'
#' @inheritParams bcdc_get_data
#'
#' @examples
#' \dontrun{
#' bcdc_preview("regional-districts-legally-defined-administrative-areas-of-bc")
#' bcdc_preview("points-of-well-diversion-applications")
#' }
#' @export
bcdc_preview <- function(x = NULL) {
  if(!has_internet()) stop("No access to internet", call. = FALSE)

  obj <- bcdc_get_record(x)

  wms_url <- "http://openmaps.gov.bc.ca/geo/pub/wms"

  wms_options <- leaflet::WMSTileOptions(format = "image/png",
                          transparent = TRUE,
                          attribution = "BC Data Catalogue (https://catalogue.data.gov.bc.ca/)")

  wms_legend <- glue::glue("{wms_url}?request=GetLegendGraphic&
             format=image%2Fpng&
             width=20&
             height=20&
             layer=pub%3A{obj$layer_name}")


  leaflet::leaflet() %>%
    leaflet::addProviderTiles(leaflet::providers$CartoDB.DarkMatter,
                     options = leaflet::providerTileOptions(noWrap = TRUE)) %>%
    leaflet::addWMSTiles(wms_url,
                layers=glue::glue("pub:{obj$layer_name}"),
                options = wms_options) %>%
    leaflet.extras::addWMSLegend(uri = wms_legend) %>%
    leaflet::setView(lng = -126.5, lat = 54.5, zoom = 5)

}

