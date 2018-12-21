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
#' Pulls features off the web
#'
#' @param feature_name Name of the feature
#' @param ... passed to \code{sf::read_sf}
#'
#' @export
#'
#' @examples
#'
#' bcdc_wfs("WHSE_WATER_MANAGEMENT.WRIS_DAMS_PUBLIC_SVW")
#' bcdc_wfs("WHSE_ENVIRONMENTAL_MONITORING.ENVCAN_HYDROMETRIC_STN_SP")

bcdc_get_geodata <- function(feature_name = NULL, ...) {

  cli <- crul::HttpClient$new(url = "https://openmaps.gov.bc.ca/geo/pub/wfs",
                              headers = list(`User-Agent` = "https://github.com/bcgov/bcdata"))

  r <- cli$get(query = list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "json",
    typeName = feature_name,
    SRSNAME="EPSG:3005"
  ))


  txt <- r$parse("UTF-8")

  raw_sf <- sf::read_sf(txt, stringsAsFactors = FALSE, quiet = TRUE, ...)
  sf::st_transform(raw_sf, 3005)
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
#' ## So far only works with this layer
#' bbox_coords = "1069159.051186301,1050414.7675306,1074045.5446851396,1054614.0978811644"
#' bcdc_wms("WHSE_FOREST_VEGETATION.VEG_COMP_LYR_R1_POLY", bbox = bbox_coords)

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

