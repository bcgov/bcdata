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
#' See `bcdc_get_record(id)$resources`)
#'
#' @param id the name of the record
#' @param crs the epsg code for the coordinate reference system. Default `3005`
#'        (B.C. Albers). See https://epsgi.io.
#' @param query A valid [`CQL` or `ECQL` query](https://docs.geoserver.org/stable/en/user/tutorials/cql/cql_tutorial.html)
#'        to filter the results. Default `NULL` (return all objects)
#' @param ... passed to \code{sf::read_sf}
#'
#' @return an `sf` object
#'
#' @export
#'
#' @examples
#'
#' bcdc_get_geodata("bc-airports", crs = 3857)
#' bcdc_get_geodata("bc-airports", crs = 3857, query = "PHYSICAL_ADDRESS='Victoria, BC'")
#' bcdc_get_geodata("ground-water-wells", query = "OBSERVATION_WELL_NUMBER=108")

bcdc_get_geodata <- function(id = NULL, query = NULL, crs = 3005, ...) {

  obj = bcdc_get_record(id)
  if (!"wms" %in% vapply(obj$resources, `[[`, "format", FUN.VALUE = character(1))) {
    stop("No wms/wfs resource available for this dataset.")
  }

  ## Parameters for the API call
  query_list = list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "json",
    typeName = obj$layer_name,
    SRSNAME=paste0("EPSG:",crs),
    CQL_FILTER = query
  )

  ## Drop any NULLS from the list
  query_list = compact(query_list)

  ## GET and parse data to sf object
  cli = bcdc_http_client(url = "https://openmaps.gov.bc.ca/geo/pub/wfs")
  r = cli$get(query = query_list)
  r$raise_for_status()
  txt = r$parse("UTF-8")
  sf::read_sf(txt, stringsAsFactors = FALSE, quiet = TRUE, ...)

}


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

