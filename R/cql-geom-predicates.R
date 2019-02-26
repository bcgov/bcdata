# Copyright 2019 Province of British Columbia
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

#' Create CQL filter strings from sf objects
#'
#' Convenience wrapper to convert sf objects and geometric operations into CQL
#' filter strings which can then be supplied to the query argument in
#' \code{bcdc_get_geodata}. The sf object is automatically converted in a
#' bounding box to reduce the complexity of the wfs call. Subsequent in-memory
#' filtering may be need to achieve exact results.
#'
#' @param x object of class sf, sfc or sfg
#' @param geometry_predicates Geometry predicates that allow for spatial filtering.
#' bcbdc_cql_string accepts the following geometric predicates: EQUALS,
#' DISJOINT, INTERSECTS, TOUCHES, CROSSES,  WITHIN, CONTAINS, OVERLAPS, RELATE,
#' DWITHIN, BEYOND.
#'
#' @examples
#' airports <- bcdc_get_geodata("bc-airports")
#' bcdc_cql_string(airports, "DWITHIN")
#'
#' @export
bcdc_cql_string <- function(x, geometry_predicates){

  if (!any(class(x) == "sf")) stop(paste(deparse(substitute(x)), "is not a valid sf object"), call. = FALSE)

  match.arg(geometry_predicates, cql_geom_predicate_list())
  x = sf::st_bbox(x)
  x = sf::st_as_sfc(x)
  x = sf::st_as_text(x)
  paste0(geometry_predicates, "(GEOMETRY, ", x,")")
}

## Geometry Predicates

cql_geom_predicate_list <- function() {
  c("EQUALS","DISJOINT","INTERSECTS",
    "TOUCHES", "CROSSES", "WITHIN",
    "CONTAINS","OVERLAPS", "RELATE",
    "DWITHIN", "BEYOND")
}

# Separate functions for all CQL geometry predicates

#' CQL Geometry Predicates
#'
#' Functions to construct a CQL expression to be used
#' to filter results from [bcdc_get_geodata()]
#'
#' @param geom an sf object
#' @name cql_geom_predicates
#' @return a CQL expression using the bounding box of the geom
NULL

#' @rdname cql_geom_predicates
#' @export
EQUALS <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "EQUALS"))
}

#' @rdname cql_geom_predicates
#' @export
DISJOINT <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "DISJOINT"))
}

#' @rdname cql_geom_predicates
#' @export
INTERSECTS <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "INTERSECTS"))
}

#' @rdname cql_geom_predicates
#' @export
TOUCHES <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "TOUCHES"))
}

#' @rdname cql_geom_predicates
#' @export
CROSSES <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "CROSSES"))
}

#' @rdname cql_geom_predicates
#' @export
WITHIN <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "WITHIN"))
}

#' @rdname cql_geom_predicates
#' @export
CONTAINS <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "CONTAINS"))
}

#' @rdname cql_geom_predicates
#' @export
OVERLAPS <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "OVERLAPS"))
}

#' @rdname cql_geom_predicates
#' @export
RELATE <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "RELATE"))
}

#' @rdname cql_geom_predicates
#' @export
DWITHIN <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "DWITHIN"))
}

#' @rdname cql_geom_predicates
#' @export
BEYOND <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "BEYOND"))
}
