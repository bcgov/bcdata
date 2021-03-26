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

#' Retrieve options used in bcdata, their value if set and the default value.
#'
#' This function retrieves bcdata specific options that can be set. These options can be set
#' using `option({name of the option} = {value of the option})`. The default options are purposefully
#' set conservatively to hopefully ensure successful requests. Resetting these options may result in
#' failed calls to the data catalogue. Options in R are reset every time R is re-started. See examples for
#' addition ways to restore your initial state.
#'
#' `bcdata.max_geom_pred_size` is the maximum size of an object used for a geometric operation. Objects
#' that are bigger than this value will have a bounding box drawn and apply the geometric operation
#' on that simpler polygon. Users can try to increase the maximum geometric predicate size and see
#' if the bcdata catalogue accepts their request.
#'
#' `bcdata.chunk_limit` is an option useful when dealing with very large data sets. When requesting large objects
#' from the catalogue, the request is broken up into smaller chunks which are then recombined after they've
#' been downloaded. This is called "pagination". bcdata does this all for you but using this option you can set the size of the chunk
#' requested. On faster internet connections, a bigger chunk limit could be useful while on slower connections,
#' it is advisable to lower the chunk limit. Chunks must be less than 10000.
#'
#' `bcdata.single_download_limit` is the maximum number of records an object can be before forcing a paginated download
#' (see entry for `bcdata.chunk_limit` for details on pagination).
#' Tweaking this option in conjunction with `bcdata.chunk_limit` can often resolve failures in large and complex downloads.
#' The default is 10000 records.
#'
#' @examples
#' \donttest{
#' ## Save initial conditions
#' try(
#'   original_options <- options()
#' )
#'
#' ## See initial options
#' try(
#'   bcdc_options()
#' )
#'
#' try(
#'   options(bcdata.max_geom_pred_size = 1E6)
#' )
#'
#' ## See updated options
#' try(
#'   bcdc_options()
#' )
#'
#' ## Reset initial conditions
#' try(
#'  options(original_options)
#' )
#' }
#' @export

bcdc_options <- function() {
  null_to_na <- function(x) {
    ifelse(is.null(x), NA, as.numeric(x))
  }

  dplyr::tribble(
    ~ option, ~ value, ~default,
    "bcdata.max_geom_pred_size", null_to_na(getOption("bcdata.max_geom_pred_size")), 5E5,
    "bcdata.chunk_limit", null_to_na(getOption("bcdata.chunk_limit")), 1000,
    "bcdata.single_download_limit", null_to_na(getOption("bcdata.single_download_limit")), 10000
  )
}

check_chunk_limit <- function(){
  chunk_value <- options("bcdata.chunk_limit")$bcdata.chunk_limit
  chunk_limit <- options("bcdata.single_download_limit")

  if(!is.null(chunk_value) && chunk_value >= chunk_limit){
    stop(glue::glue("Your chunk value of {chunk_value} exceed the BC Data Catalogue chunk limit of {chunk_limit}"), call. = FALSE)
  }
}


bcdc_single_download_limit <- function() {
  if(!has_internet()) stop("No access to internet", call. = FALSE) # nocov
  url <- "http://openmaps.gov.bc.ca/geo/pub/ows?service=WFS&version=2.0.0&request=Getcapabilities"
  cli <- bcdata:::bcdc_http_client(url, auth = FALSE)
  if (has_internet()) {
    url <- "http://openmaps.gov.bc.ca/geo/pub/ows?service=WFS&version=2.0.0&request=Getcapabilities"
    cli <- bcdata:::bcdc_http_client(url, auth = FALSE)

    cc <- cli$get(query = list(
      SERVICE = "WFS",
      VERSION = "2.0.0",
      REQUEST = "Getcapabilities"
    ))

    res <- cc$parse("UTF-8")
    doc <- xml2::read_xml(res)

    constraints <- xml2::xml_find_all(doc, ".//ows:Constraint")
    count_defaults <- constraints[which(xml2::xml_attrs(constraints) %in% "CountDefault")]
    xml2::xml_double(count_defaults)
  } else {
    message("No access to internet")
    10000L
  }
}
