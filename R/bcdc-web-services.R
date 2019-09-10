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


#' Query data from the B.C. Web Service
#'
#' Queries features from the B.C. Web Service. The data must be available as
#' a Web Service. See `bcdc_get_record(record)$resources`). If the record is greater than 10000 rows,
#' the response will be paginated. If you are querying layers of this size, expect
#' that the request will take quite a while.
#'
#' Note that this function doesn't actually return the data, but rather an
#' object of class `bcdc_promise``, which includes all of the information
#' required to retrieve the requested data. In order to get the actual data as
#' an `sf` object, you need to run [collect()] on the `bcdc_promise`. This
#' allows further refining the call to `bcdc_query_geodata()` with [filter()]
#' and/or [select()] statements before pulling down the actual data as an `sf`
#' object with [collect()]. See examples.
#'
#' @inheritParams bcdc_get_data
#' @param crs the epsg code for the coordinate reference system. Defaults to
#'   `3005` (B.C. Albers). See https://epsgi.io.
#'
#' @return A `bcdc_promise` object. This object includes all of the information
#'   required to retrieve the requested data. In order to get the actual data as
#'   an `sf` object, you need to run [collect()] on the `bcdc_promise`.
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' # Returns a bcdc_promise, which can be further refined using filter/select:
#' bcdc_query_geodata("bc-airports", crs = 3857)
#'
#' To obtain the actual data as an sf object, collect() must be called:
#' bcdc_query_geodata("bc-airports", crs = 3857) %>%
#'   filter(PHYSICAL_ADDRESS == 'Victoria, BC') %>%
#'   collect()
#'
#' bcdc_query_geodata("ground-water-wells") %>%
#'   filter(OBSERVATION_WELL_NUMBER == 108) %>%
#'   select(WELL_TAG_NUMBER, WATERSHED_CODE) %>%
#'   collect()
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
#' @export
bcdc_query_geodata <- function(record, crs = 3005) {
  if (!has_internet()) stop("No access to internet", call. = FALSE)
  UseMethod("bcdc_query_geodata")
}

#' @export
bcdc_query_geodata.default <- function(record, crs = 3005) {
  stop("No bcdc_query_geodata method for an object of class ", class(record),
       call. = FALSE)
}

#' @export
bcdc_query_geodata.character <- function(record, crs = 3005) {
  obj <- bcdc_get_record(record)

  bcdc_query_geodata(obj, crs)
}

#' @export
bcdc_query_geodata.bcdc_record <- function(record, crs = 3005) {
  if (!any(wfs_available(record$resource_df))) {
    stop("No Web Service resource available for this dataset.",
         call. = FALSE
    )
  }

  ## Parameters for the API call
  query_list <- list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = record$layer_name,
    SRSNAME = paste0("EPSG:", crs)
  )

  ## Drop any NULLS from the list
  query_list <- compact(query_list)

  ## GET and parse data to sf object
  cli <- bcdc_http_client(url = "https://openmaps.gov.bc.ca/geo/pub/wfs")

  as.bcdc_promise(list(query_list = query_list, cli = cli, obj = record))
}

#' Get map from the B.C. Web Service
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
bcdc_preview <- function(record) {
  if (!has_internet()) stop("No access to internet", call. = FALSE)
  UseMethod("bcdc_preview")
}

#' @export
bcdc_preview.default <- function(record) {
  stop("No bcdc_preview method for an object of class ", class(record),
       call. = FALSE)
}

#' @export
bcdc_preview.character <- function(record) {
  bcdc_preview(bcdc_get_record(record))
}

#' @export
bcdc_preview.bcdc_record <- function(record) {

  wms_url <- "http://openmaps.gov.bc.ca/geo/pub/wms"

  wms_options <- leaflet::WMSTileOptions(format = "image/png",
                          transparent = TRUE,
                          attribution = "BC Data Catalogue (https://catalogue.data.gov.bc.ca/)")

  wms_legend <- glue::glue("{wms_url}?request=GetLegendGraphic&
             format=image%2Fpng&
             width=20&
             height=20&
             layer=pub%3A{record$layer_name}")


  leaflet::leaflet() %>%
    leaflet::addProviderTiles(leaflet::providers$CartoDB.DarkMatter,
                     options = leaflet::providerTileOptions(noWrap = TRUE)) %>%
    leaflet::addWMSTiles(wms_url,
                layers=glue::glue("pub:{record$layer_name}"),
                options = wms_options) %>%
    leaflet.extras::addWMSLegend(uri = wms_legend) %>%
    leaflet::setView(lng = -126.5, lat = 54.5, zoom = 5)

}

