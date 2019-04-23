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

#' Download and read a dataset from a Data Catalogue resource
#'
#'
#' @param x either a `bcdc_record` object (from the result of `bcdc_get_record()`)
#' or a character string denoting the id of a resource (or the url).
#' @param format Defaults to NULL which will first check to see if the record is a wms/wfs record.
#' If so an sf object is returned. Otherwise a format needs to be specified. `bcdc_get_record` can
#' be used to identify which formats are available.
#' @param ... arguments passed to other functions. For spatial (wms/wfs) data these are passed to
#' `bcdc_query_geodata()`. Non spatial data is passed to a function to handle the import based
#' on the file extension.
#'
#' @return an object of a type relevant to the resource (usually a tibble or an sf object)
#' @export
#'
#' @examples
#' \dontrun{
#' bcdc_get_data("bc-airports")
#' bcdc_get_data("bc-winery-locations", format = "csv")
#' bcdc_get_data("local-government-population-and-household-projections-2018-2027",
#' format = "xlsx", sheet = "Population", skip = 1)
#'
#' }
bcdc_get_data <- function(x, format = NULL, ...) {
  UseMethod("bcdc_get_data")
}

#' @export
bcdc_get_data.bcdc_record <- function(x, format = NULL, ...) {
  if(!has_internet()) stop("No access to internet", call. = FALSE)

  stop("not working yet!")
  # record can be either a url/slug or a bcdata_record
  if (!interactive())
    stop("Calling bcdc_get_data on a bcdc_record object is only meant for interactive use")
  x <- utils::menu("pick one")
  bcdc_get_data(x)
}

#' @export
bcdc_get_data.character <- function(x, format = NULL, ...) {
  x <- slug_from_url(x)

  if(is.null(format)){
    query <- bcdc_query_geodata(x = x, ...)
    return(collect(query))
  }

  if(!all(format %in% c("csv","kml","txt","xlsx"))){
    stop(paste0("The ", format, " extension is not currently supported by bcdata.
                Try manually importing into R from this link: \n", file_url),
         call. = FALSE)
  }

  record <- bcdc_get_record(x)
  record_formats <- purrr::map_chr(seq_along(record$resources),
                                   ~record$resources[[.x]][["format"]])

  file_url <- record[["resources"]][[which(record_formats == format)]][["url"]]

  ## Do we need this?
  cli <- bcdc_http_client(file_url)
  r <- cli$get()
  r$raise_for_status()

  ## Download file then read it in.
  tmp <- tempfile(fileext = paste0(".", format))
  on.exit(unlink(tmp))
  utils::download.file(file_url, tmp, mode = 'wb', quiet = FALSE)

  read_fun <- function(x, type) {
    switch(type,
           "csv" = readr::read_csv(x, ...),
           "kml" = bcdc_read_sf(x, ...),
           "txt" = readr::read_tsv(x, ...),
           "xlsx" = readxl::read_excel(x, ...))
  }

  read_fun(x = tmp, type = format)

}
