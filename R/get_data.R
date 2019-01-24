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

#' downlaod and read a dataset from a Data Catalogue resource
#'
#' @param x either a `bcdc_record` object (from the result of `bcdc_get_record()`)
#' or a character string denoting the id of a resource (or the url).
#'
#' @return an object of a type relevant to the resource (usually a tibble or an sf object)
#' @export
#'
#' @examples
#' \dontrun{
#' bcdc_get_data(paste0("https://catalogue.data.gov.bc.ca/dataset/",
#'                      "british-columbia-greenhouse-gas-emissions/resource/",
#'                      "11b1da01-fabc-406c-8b13-91e87f126dec"))
#' bcdc_get_data("11b1da01-fabc-406c-8b13-91e87f126dec")
#' }
bcdc_get_data <- function(x) {
  UseMethod("bcdc_get_data")
}

#' @export
bcdc_get_data.bcdc_record <- function(x) {
  if(!has_internet()) stop("No access to internet", call. = FALSE)

  stop("not working yet!")
  # record can be either a url/slug or a bcdata_record
  if (!interactive())
    stop("Calling bcdc_get_data on a bcdc_record object is only meant for interactive use")
  x <- utils::menu("pick one")
  bcdc_get_data(x)
}

#' @export
bcdc_get_data.character <- function(x) {
  x <- slug_from_url(x)
  cli <- bcdc_http_client(paste0(base_url(),
                                 "action/resource_show"))

  r <- cli$get(query = list(id = x))
  r$raise_for_status()

  res <- jsonlite::fromJSON(r$parse("UTF-8"))
  stopifnot(res$success)

  file_url <- res$result$url
  ext <- tools::file_ext(file_url)

  tmp <- tempfile(fileext = paste0(".", ext))
  on.exit(unlink(tmp))
  utils::download.file(file_url, tmp)

  read_fun <- switch(ext,
                     "csv" = readr::read_csv)

  read_fun(tmp)

}
