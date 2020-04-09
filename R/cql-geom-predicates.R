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
#' filter strings which can then be supplied to filter.bcdc_promise.
#' The sf object is automatically converted in a
#' bounding box to reduce the complexity of the Web Service call. Subsequent in-memory
#' filtering may be need to achieve exact results.
#'
#'
#' @param x object of class sf, sfc or sfg
#' @param geometry_predicates Geometry predicates that allow for spatial filtering.
#' bcbdc_cql_string accepts the following geometric predicates: EQUALS,
#' DISJOINT, INTERSECTS, TOUCHES, CROSSES,  WITHIN, CONTAINS, OVERLAPS,
#' DWITHIN, BBOX.
#'
#' @seealso sql_geom_predicates
#'
#' @examples
#' \donttest{
#' airports <- bcdc_query_geodata("bc-airports") %>% collect()
#' bcdc_cql_string(airports, "DWITHIN")
#' }
#'
#' @noRd
bcdc_cql_string <- function(x, geometry_predicates, pattern = NULL,
                            distance = NULL, units = NULL,
                            coords = NULL, crs = NULL){

  if (inherits(x, "sql")) {
    stop(glue::glue("object {as.character(x)} not found.\n The object passed to {geometry_predicates} needs to be valid sf object."),
         call. = FALSE)
  }

  if (inherits(x, "bcdc_promise")) {
    stop("To use spatial operators, you need to use collect() to retrieve the object used to filter",
         call. = FALSE)
  }

  match.arg(geometry_predicates, cql_geom_predicate_list())

  # Only convert x to bbox if not using BBOX CQL function
  # because it doesn't take a geom
  if (!geometry_predicates == "BBOX") {
    x <- sf_text(x)
  }

  cql_args <-
    if (geometry_predicates == "BBOX") {
      paste0(
        paste0(coords, collapse = ", "),
        if (!is.null(crs)) paste0(", '", crs, "'")
      )
    } else if (geometry_predicates %in% c("DWITHIN", "BEYOND")) {
      paste0(x, ", ", distance, ", ", units, "")
    } else if (geometry_predicates == "RELATE") {
      paste0(x, ", ", pattern)
    } else {
      x
    }

  CQL(paste0(geometry_predicates,"({geom_name}, ", cql_args, ")"))
}

## Geometry Predicates

cql_geom_predicate_list <- function() {
  c("EQUALS","DISJOINT","INTERSECTS",
    "TOUCHES", "CROSSES", "WITHIN",
    "CONTAINS","OVERLAPS", "RELATE",
    "DWITHIN", "BEYOND", "BBOX")
}

sf_text <- function(x) {

  if (!inherits(x, c("sf", "sfc", "sfg", "bbox"))) {
    stop(paste(deparse(substitute(x)), "is not a valid sf object"),
         call. = FALSE)
  }

  ## If too big here, drawing bounding
  if (utils::object.size(x) > getOption("bcdata.max_geom_pred_size", 5E5)) {
    warning("The object is too large to perform exact spatial operations using bcdata.
             To simplify the polygon, a bounding box was drawn around the polygon and all
             features within the box will be returned. Options include further processing
             with on the returned object or simplify the object.", call. = FALSE)
    x <- sf::st_bbox(x)
  }

  if (inherits(x, "bbox")) {
    x <- sf::st_as_sfc(x)
  } else {
    x <- sf::st_union(x)
  }

  sf::st_as_text(x)
}

# Separate functions for all CQL geometry predicates

#' CQL Geometry Predicates
#'
#' Functions to construct a CQL expression to be used
#' to filter results from [bcdc_query_geodata()].
#' See [the geoserver CQL documentation for details](https://docs.geoserver.org/stable/en/user/filter/ecql_reference.html#spatial-predicate).
#' The sf object is automatically converted in a
#' bounding box to reduce the complexity of the Web Service call. Subsequent in-memory
#' filtering may be needed to achieve exact results.
#'
#' @param geom an `sf`/`sfc`/`sfg` or `bbox` object (from the `sf` package)
#' @name cql_geom_predicates
#' @return a CQL expression to be passed on to the WFS call
NULL

#' @rdname cql_geom_predicates
#' @export
EQUALS <- function(geom) {
  bcdc_cql_string(geom, "EQUALS")
}

#' @rdname cql_geom_predicates
#' @export
DISJOINT <- function(geom) {
  bcdc_cql_string(geom, "DISJOINT")
}

#' @rdname cql_geom_predicates
#' @export
INTERSECTS <- function(geom) {
  bcdc_cql_string(geom, "INTERSECTS")
}

#' @rdname cql_geom_predicates
#' @export
TOUCHES <- function(geom) {
  bcdc_cql_string(geom, "TOUCHES")
}

#' @rdname cql_geom_predicates
#' @export
CROSSES <- function(geom) {
  bcdc_cql_string(geom, "CROSSES")
}

#' @rdname cql_geom_predicates
#' @export
WITHIN <- function(geom) {
  bcdc_cql_string(geom, "WITHIN")
}

#' @rdname cql_geom_predicates
#' @export
CONTAINS <- function(geom) {
  bcdc_cql_string(geom, "CONTAINS")
}

#' @rdname cql_geom_predicates
#' @export
OVERLAPS <- function(geom) {
  bcdc_cql_string(geom, "OVERLAPS")
}

#' @rdname cql_geom_predicates
#' @param pattern spatial relationship specified by a DE-9IM matrix pattern.
#' A DE-9IM pattern is a string of length 9 specified using the characters
#' `*TF012`. Example: `'1*T***T**'`
#' @noRd
RELATE <- function(geom, pattern) {
  if (!is.character(pattern) ||
      length(pattern) != 1L ||
      !grepl("^[*TF012]{9}$", pattern)) {
    stop("pattern must be a 9-character string using the characters '*TF012'",
         call. = FALSE)
  }
  bcdc_cql_string(geom, "RELATE", pattern = pattern)
}

#' @rdname cql_geom_predicates
#' @param coords the coordinates of the bounding box as four-element numeric
#'        vector `c(xmin, ymin, xmax, ymax)`, or a `bbox` object from the `sf`
#'        package (the result of running `sf::st_bbox()` on an `sf` object).
#' @param crs (Optional) A numeric value or string containing an SRS code. If
#' `coords` is a `bbox` object with non-empty crs, it is taken from that.
#' (For example, `'EPSG:3005'` or just `3005`. The default is to use the CRS of
#' the queried layer)
#' @export
BBOX <- function(coords, crs = NULL){

  if (!is.numeric(coords) || length(coords) != 4L) {
    stop("'coords' must be a length 4 numeric vector", call. = FALSE)
  }

  if (inherits(coords, "bbox")) {
    crs <- sf::st_crs(coords)$epsg
    coords <- as.numeric(coords)
  }

  if (is.integer(crs)) {
    crs <- paste0("EPSG:", crs)
  }

  if (!is.null(crs) && !(is.character(crs) && length(crs) == 1L)) {
    stop("crs must be a character string denoting the CRS (e.g., 'EPSG:4326')",
         call. = FALSE)
  }
  bcdc_cql_string(x = NULL, "BBOX", coords = coords, crs = crs)
}

#' @rdname cql_geom_predicates
#' @param distance numeric value for distance tolerance
#' @param units units that distance is specified in. One of
#' `"feet"`, `"meters"`, `"statute miles"`, `"nautical miles"`, `"kilometers"`
#' @export
DWITHIN <- function(geom, distance,
                    units = c("meters", "feet", "statute miles", "nautical miles", "kilometers")) {
  if (!is.numeric(distance)) {
    stop("'distance' must be numeric", call. = FALSE)
  }
  units <- match.arg(units)
  bcdc_cql_string(geom, "DWITHIN", distance = distance, units = units)
}

#' @rdname cql_geom_predicates
#' @noRd
# https://osgeo-org.atlassian.net/browse/GEOS-8922
BEYOND <- function(geom, distance,
                   units = c("meters", "feet", "statute miles", "nautical miles", "kilometers")) {
  if (!is.numeric(distance)) {
    stop("'distance' must be numeric", call. = FALSE)
  }
  units <- match.arg(units)
  bcdc_cql_string(geom, "BEYOND", distance = distance, units = units)
}
