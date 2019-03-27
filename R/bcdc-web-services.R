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


#' Get data from the BC Web Feature Service
#'
#' Pulls features off the web. The data must be available as a wms/wfs service.
#' See `bcdc_get_record(x)$resources`). If the record is greater than 10000 rows,
#' the response will be paginated. If you are querying layers of this size, expect
#' that the request will take quite a while.
#'
#' @inheritParams bcdc_get_data
#' @param ... Logical predicates with which to filter the results. Multiple
#' conditions are combined with `&`. Only rows where the condition evalueates to
#' `TRUE` are kept. Accepts normal R expressions as well as any of the special
#' [CQL geometry functions][cql_geom_predicates] such as `WITHIN()` or `INTERSECTS()`.
#' If you know `CQL` and want to write a `CQL` query directly, write it enclosed
#' in quotes, wrapped in the [CQL()] function. e.g., `CQL("ID = '42'")`
#' @param crs the epsg code for the coordinate reference system. Defaults to `3005`
#'        (B.C. Albers). See https://epsgi.io.
#'
#' @return an `sf` object
#'
#' @export
#'
#' @examples
#'
#' bcdc_get_geodata("bc-airports", crs = 3857)
#' bcdc_get_geodata("bc-airports", PHYSICAL_ADDRESS == 'Victoria, BC', crs = 3857)
#' bcdc_get_geodata("ground-water-wells", OBSERVATION_WELL_NUMBER == 108)
#' bcdc_get_geodata("bc-airports", CQL("LATITUDE > 50"))
#'
#' ## A very large layer
#' \dontrun{
#' bcdc_get_geodata("terrestrial-protected-areas-representation-by-biogeoclimatic-unit")
#' }
#'
bcdc_get_geodata <- function(x = NULL, ..., crs = 3005) {
  obj <- bcdc_get_record(x)
  if (!"wms" %in% vapply(obj$resources, `[[`, "format", FUN.VALUE = character(1))) {
    stop("No wms/wfs resource available for this dataset.",
      call. = FALSE
    )
  }

  query <- cql_translate(...)

  ## Parameters for the API call
  query_list <- list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = obj$layer_name,
    SRSNAME = paste0("EPSG:", crs),
    CQL_FILTER = query
  )

  ## Drop any NULLS from the list
  query_list <- compact(query_list)

  ## GET and parse data to sf object
  cli <- bcdc_http_client(url = "https://openmaps.gov.bc.ca/geo/pub/wfs")

  ## Change CQL query on the fly if geom is SHAPE
  query_list <- check_geom_col_names(query_list, cli)

  ## Determine total number of records for pagination purposes
  number_of_records <- bcdc_number_wfs_records(query_list, cli)

  if (number_of_records < 10000) {
    r <- cli$get(query = query_list)
    r$raise_for_status()
    txt <- r$parse("UTF-8")

    return(bcdc_read_sf(txt))
  }

  if (number_of_records >= 10000) {
    message("This record requires pagination to complete the request.")
    sorting_col <- obj[["details"]][["column_name"]][1]

    query_list <- c(query_list, sortby = sorting_col)

    # Create pagination client
    cc <- crul::Paginator$new(
      client = cli,
      by = "query_params",
      limit_param = "count",
      offset_param = "startIndex",
      limit = number_of_records,
      limit_chunk = 3000
    )

    message("Retrieving data")
    cc$get(query = query_list)


    if (any(cc$status_code() >= 300)) {
      ## TODO: This error message could be more informative
      stop("The BC data catalogue experienced issues with this request",
        call. = FALSE
      )
    }

    ## Parse the Paginated response
    message("Parsing data")
    txt <- cc$parse("UTF-8")

    sf_responses <- lapply(txt, bcdc_read_sf)

    return(do.call(rbind, sf_responses))
  }
}

# bcdc_get_geodata <- memoise::memoise(bcdc_get_geodata_)

#' Get map from the BC Web Mapping Service
#'
#' Pulls map off the web
#'
#' @param feature_name Name of the feature
#' @param bbox a string of bounding box coordinates
#'
#'
#' @examples
#' \dontrun{
#' ## So far only works with this layer
#' bbox_coords = "1069159.051186301,1050414.7675306,1074045.5446851396,1054614.0978811644"
#' bcdc_wms("WHSE_FOREST_VEGETATION.VEG_COMP_LYR_R1_POLY", bbox = bbox_coords)
#' }

## TODO: Figure out a better method of determining the bounding box

bcdc_wms <- function(feature_name = NULL, bbox = NULL) {
  if(!has_internet()) stop("No access to internet", call. = FALSE)

  cli <- crul::HttpClient$new(url = "http://openmaps.gov.bc.ca/geo/pub/wms",
                              headers = list(`User-Agent` = "https://github.com/bcgov/bcdc"))

  r <- cli$get(query = list(
    SERVICE = "WMS",
    VERSION = "1.1.1",
    REQUEST = "GetMap",
    FORMAT = "application/openlayers",
    TRANSPARENT="true",
    STYLES=1748,
    LAYERS = feature_name,
    SRS="EPSG:3005",
    WIDTH = "512",
    HEIGHT = "440",
    BBOX = bbox
  ))

  ##TODO:: Viewer should be able to accept this somehow much mapview
  # Possible solution: write html to a local temp file then access that
  utils::browseURL(r$url)

}

