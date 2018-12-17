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

#' Get a map from a B.C. Data Catalogue record.
#'
#' The data must be available as a wms service. See `bcdc_show(id)$resources`)
#'
#' @param id the name of the record
#' @param epsg the epsg code for the coordinate reference system. Default `3005`
#'        (B.C. Albers). See https://epsgi.io.
#' @param query A valid [`CQL` or `ECQL` query](https://docs.geoserver.org/stable/en/user/tutorials/cql/cql_tutorial.html)
#'        to filter the results. Default `NULL` (return all objects)
#'
#' @return an `sf` map object
#' @export
#'
#' @examples
#' bcdc_map("bc-airports")
bcdc_map <- function(id, epsg = 3005, query = NULL) {
  obj <- bcdc_show(id)
  if (!"wms" %in% vapply(obj$resources, `[[`, "format", FUN.VALUE = character(1))) {
    stop("No wms resource available for this dataset.")
  }
  url <- construct_url(obj$layer_name, epsg, query = query)
  tmp <- tempfile(fileext = ".json")
  on.exit(unlink(tmp))
  res <- httr::GET(url, httr::write_disk(tmp))
  httr::stop_for_status(res)
  sf::st_read(tmp)
}

construct_url <- function(obj, epsg, query) {
  baseurl <- "https://openmaps.gov.bc.ca/geo/pub/{obj}/ows?service=WFS&version=2.0.0&request=GetFeature&typeName={obj}&SRSNAME=epsg:{epsg}&outputFormat=json{query}"

  if (!is.null(query)) {
    query <- paste0("&CQL_FILTER=", query)
  } else {
    query <- ""
  }
  utils::URLencode(glue::glue(baseurl, obj = obj, epsg = epsg, query = query))
}
