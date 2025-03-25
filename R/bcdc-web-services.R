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

#' Query data from the B.C. Web Feature Service
#'
#' Queries features from the B.C. Web Feature Service. See
#' [bcdc_tidy_resources()] - if a resource has a value of
#' `"wms"` in the `format` column it is available as a Web
#' Feature Service, and you can query and download it
#' using `bcdc_query_geodata()`. The response will be
#' paginated if the number of features is greater than that allowed by the server.
#' Please see [bcdc_options()] for defaults and more
#' information.
#'
#' Note that this function doesn't actually return the data, but rather an
#' object of class `bcdc_promise`, which includes all of the information
#' required to retrieve the requested data. In order to get the actual data as
#' an `sf` object, you need to run [collect()] on the `bcdc_promise`. This
#' allows further refining the call to `bcdc_query_geodata()` with [filter()]
#' and/or [select()] statements before pulling down the actual data as an `sf`
#' object with [collect()]. See examples.
#'
#' @inheritParams bcdc_get_data
#' @param crs the epsg code for the coordinate reference system. Defaults to
#'   `3005` (B.C. Albers). See https://epsg.io.
#'
#' @return A `bcdc_promise` object. This object includes all of the information
#'   required to retrieve the requested data. In order to get the actual data as
#'   an `sf` object, you need to run [collect()] on the `bcdc_promise`.
#'
#' @export
#'
#' @examples
#'
#' \donttest{
#' # Returns a bcdc_promise, which can be further refined using filter/select:
#' try(
#'   res <- bcdc_query_geodata("bc-airports", crs = 3857)
#' )
#'
#' # To obtain the actual data as an sf object, collect() must be called:
#' try(
#'   res <- bcdc_query_geodata("bc-airports", crs = 3857) %>%
#'     filter(PHYSICAL_ADDRESS == 'Victoria, BC') %>%
#'     collect()
#' )
#'
#' # To query based on partial matches, use %LIKE%:
#' try(
#'   res <- bcdc_query_geodata("bc-airports") %>%
#'     filter(PHYSICAL_ADDRESS %LIKE% 'Vict%')
#' )
#'
#' # To query using %IN%
#' try(
#'   res <- bcdc_query_geodata("bc-airports") %>%
#'     filter(
#'       AIRPORT_NAME %IN%
#'         c(
#'           "Victoria Harbour (Camel Point) Heliport",
#'           "Victoria Harbour (Shoal Point) Heliport"
#'         )
#'     ) %>%
#'     collect()
#' )
#'
#'
#' try(
#'   res <- bcdc_query_geodata("groundwater-wells") %>%
#'     filter(OBSERVATION_WELL_NUMBER == "108") %>%
#'     select(WELL_TAG_NUMBER, INTENDED_WATER_USE) %>%
#'     collect()
#' )
#'
#' ## A moderately large layer
#' try(
#'   res <- bcdc_query_geodata("bc-environmental-monitoring-locations")
#' )
#'
#' try(
#'   res <- bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
#'     filter(PERMIT_RELATIONSHIP == "DISCHARGE")
#' )
#'
#'
#' ## A very large layer
#' try(
#'   res <- bcdc_query_geodata("terrestrial-protected-areas-representation-by-biogeoclimatic-unit")
#' )
#'
#' ## Using a BCGW name
#' try(
#'   res <- bcdc_query_geodata("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
#' )
#' }
#' @export
bcdc_query_geodata <- function(record, crs = 3005) {
  if (!has_internet()) stop("No access to internet", call. = FALSE) # nocov
  UseMethod("bcdc_query_geodata")
}

#' @export
bcdc_query_geodata.default <- function(record, crs = 3005) {
  stop(
    "No bcdc_query_geodata method for an object of class ",
    class(record),
    call. = FALSE
  )
}

#' @export
bcdc_query_geodata.character <- function(record, crs = 3005) {
  if (length(record) != 1) {
    stop("Only one record my be queried at a time.", call. = FALSE)
  }

  # Fist catch if a user has passed the name of a warehouse object directly,
  # then can skip all the record parsing and make the API call directly
  if (is_whse_object_name(record)) {
    ## Parameters for the API call
    query_list <- make_query_list(layer_name = record, crs = crs)

    ## Drop any NULLS from the list
    query_list <- compact(query_list)

    ## GET and parse data to sf object
    cli <- bcdc_wfs_client()

    cols_df <- feature_helper(record)

    return(
      as.bcdc_promise(list(
        query_list = query_list,
        cli = cli,
        record = NULL,
        cols_df = cols_df
      ))
    )
  }

  if (grepl("/resource/", record)) {
    #  A full url was passed including record and resource compenents.
    # Grab the resource id and strip it off the url
    record <- gsub("/resource/.+", "", record)
  }

  obj <- bcdc_get_record(record)

  bcdc_query_geodata(obj, crs)
}

#' @export
bcdc_query_geodata.bcdc_record <- function(record, crs = 3005) {
  if (!any(wfs_available(record$resource_df))) {
    stop(
      "No Web Feature Service resource available for this data set.",
      call. = FALSE
    )
  }

  wfs_resource <- get_wfs_resource_from_record(record)
  # Need to get layer name from wms url rather than
  # object_name field, sometimes they don't match
  # (e.g., if a generalized view is available from wms)
  layer_name <- basename(dirname(
    wfs_resource$url
  ))

  if (grepl("_SP?G$", layer_name)) {
    message(
      "You are accessing a simplified view of the data - see the catalogue record for details."
    )
  }

  ## Parameters for the API call
  query_list <- make_query_list(layer_name = layer_name, crs = crs)

  ## Drop any NULLS from the list
  query_list <- compact(query_list)

  ## GET and parse data to sf object
  cli <- bcdc_wfs_client()

  cols_df <- feature_helper(query_list$typeNames)

  as.bcdc_promise(list(
    query_list = query_list,
    cli = cli,
    record = record,
    cols_df = cols_df
  ))
}

#' Get preview map from the B.C. Web Map Service
#'
#' Note this does not return the actual map features, rather
#' opens an image preview of the layer in a
#' [Leaflet](https://rstudio.github.io/leaflet/) map window
#'
#'
#' @inheritParams bcdc_get_data
#'
#' @examples
#' \donttest{
#' try(
#'   bcdc_preview("regional-districts-legally-defined-administrative-areas-of-bc")
#' )
#'
#' try(
#'   bcdc_preview("water-reservations-points")
#' )
#'
#' # Using BCGW name
#' try(
#'   bcdc_preview("WHSE_LEGAL_ADMIN_BOUNDARIES.ABMS_REGIONAL_DISTRICTS_SP")
#' )
#' }
#' @export
bcdc_preview <- function(record) {
  # nocov start
  if (!has_internet()) stop("No access to internet", call. = FALSE)
  UseMethod("bcdc_preview")
}

#' @export
bcdc_preview.default <- function(record) {
  stop(
    "No bcdc_preview method for an object of class ",
    class(record),
    call. = FALSE
  )
}

#' @export
bcdc_preview.character <- function(record) {
  if (is_whse_object_name(record)) {
    make_wms(record)
  } else {
    bcdc_preview(bcdc_get_record(record))
  }
}

#' @export
bcdc_preview.bcdc_record <- function(record) {
  wfs_resource <- get_wfs_resource_from_record(record)

  make_wms(basename(dirname(wfs_resource$url)))
}

make_wms <- function(x) {
  wms_url <- wms_base_url()
  wms_options <- leaflet::WMSTileOptions(
    format = "image/png",
    transparent = TRUE,
    attribution = "BC Data Catalogue (https://catalogue.data.gov.bc.ca/)"
  )
  wms_legend <- glue::glue(
    "{wms_url}?request=GetLegendGraphic&
             format=image%2Fpng&
             width=20&
             height=20&
             layer=pub%3A{x}"
  )

  leaflet::leaflet() %>%
    leaflet::addProviderTiles(
      leaflet::providers$CartoDB.Positron,
      options = leaflet::providerTileOptions(noWrap = TRUE)
    ) %>%
    leaflet::addWMSTiles(
      wms_url,
      layers = glue::glue("pub:{x}"),
      options = wms_options
    ) %>%
    leaflet.extras::addWMSLegend(uri = wms_legend) %>%
    leaflet::setView(lng = -126.5, lat = 54.5, zoom = 5)
} # nocov end


make_query_list <- function(layer_name, crs) {
  list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = layer_name,
    SRSNAME = paste0("EPSG:", crs)
  )
}
