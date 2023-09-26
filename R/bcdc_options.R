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
#' `bcdata.max_geom_pred_size` is the maximum size in bytes of an object used for a geometric operation. Objects
#' that are bigger than this value will have a bounding box drawn and apply the geometric operation
#' on that simpler polygon. The [bcdc_check_geom_size] function can be used to assess whether a given spatial object
#' exceed the value of this option. Users can iteratively try to increase the maximum geometric predicate size and see
#' if the bcdata catalogue accepts the request.
#'
#' `bcdata.chunk_limit` is an option useful when dealing with very large data sets. When requesting large objects
#' from the catalogue, the request is broken up into smaller chunks which are then recombined after they've
#' been downloaded. This is called "pagination". bcdata does this all for you but using this option you can set the size of the chunk
#' requested. On faster internet connections, a bigger chunk limit could be useful while on slower connections,
#' it is advisable to lower the chunk limit. The default is the same as `bcdata.single_download_limit`.
#'
#' `bcdata.single_download_limit` is the maximum number of records an object can be before forcing a paginated download
#' (see entry for `bcdata.chunk_limit` for details on pagination).
#' Tweaking this option in conjunction with `bcdata.chunk_limit` can often resolve failures in large and complex downloads.
#' The default is obtained from the server.
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
#'

bcdc_options <- function() {
  null_to_na <- function(x) {
    ifelse(is.null(x), NA, as.numeric(x))
  }

  single_download_limit <- bcdc_single_download_limit()

  dplyr::tribble(
    ~ option, ~ value, ~default,
    "bcdata.max_geom_pred_size", null_to_na(getOption("bcdata.max_geom_pred_size")), 5E5,
    "bcdata.chunk_limit", null_to_na(getOption("bcdata.chunk_limit")), single_download_limit,
    "bcdata.single_download_limit",
    null_to_na(getOption("bcdata.single_download_limit")), single_download_limit
  )
}


check_chunk_limit <- function(){
  chunk_value <- getOption("bcdata.chunk_limit", default = bcdc_single_download_limit())
  chunk_limit <- getOption("bcdata.single_download_limit", default = bcdc_single_download_limit())

  if (!is.null(chunk_value) && chunk_value > chunk_limit) {
    stop(glue::glue("Your chunk value of {chunk_value} exceed the BC Data Catalogue chunk limit of {chunk_limit}"), call. = FALSE)
  }
  chunk_value
}

bcdc_get_capabilities <- function() {
  current_xml <- ._bcdataenv_$get_capabilities_xml
  if (!is.null(current_xml) && inherits(current_xml, "xml_document")) {
    # Already retrieved and stored this session
    return(current_xml)
  }

  if (has_internet()) {
    url <- make_url(bcdc_web_service_host(https = FALSE), "geo/pub/ows")
    cli <- bcdc_http_client(url, auth = FALSE)


    cc <- try(cli$get(query = list(
      SERVICE = "WFS",
      VERSION = "2.0.0",
      REQUEST = "Getcapabilities"
    )), silent = TRUE)

    if (inherits(cc, "try-error")) {
      return(NULL)
    }

    cc$raise_for_status()

    res <- cc$parse("UTF-8")
    ret <- xml2::read_xml(res)
    # store it and return it
    ._bcdataenv_$get_capabilities_xml <- ret
    return(ret)
  }

  invisible(NULL)

}

bcdc_get_wfs_records <- function() {
  doc <- bcdc_get_capabilities()

  if (is.null(doc)) stop("Unable to access wfs record listing", call. = FALSE)

  # d1 is the default xml namespace (see xml2::xml_ns(doc))
  features <- xml2::xml_find_all(doc, "./d1:FeatureTypeList/d1:FeatureType")

  tibble::tibble(
    whse_name = gsub("^pub:", "", xml2::xml_text(xml2::xml_find_first(features, "./d1:Name"))),
    title = xml2::xml_text(xml2::xml_find_first(features, "./d1:Title")),
    cat_url = xml2::xml_attr(xml2::xml_find_first(features, "./d1:MetadataURL"), "href")
  )
}

bcdc_single_download_limit <- function() {
  doc <- bcdc_get_capabilities()

  if (is.null(doc)) {
    message("Unable to access wfs record listing, using default download limit of 10000")
    return(10000L)
  }

  count_default_xpath <- "./ows:OperationsMetadata/ows:Operation[@name='GetFeature']/ows:Constraint[@name='CountDefault']"
  # Looking globally also works but is slower: ".//ows:Constraint[@name='CountDefault']"
  count_defaults <- xml2::xml_find_first(doc, count_default_xpath)
  xml2::xml_integer(count_defaults)
}
