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

#' Load the B.C. Data Catalogue URL into an HTML browser
#'
#' This is a wrapper around utils::browseURL with the URL for the B.C. Data Catalogue as
#' the default
#'
#' @inheritParams utils::browseURL
#' @param query A string to search in the bcdata catalogue. Default (NULL) opens
#'        a browser to \code{https://catalogue.data.gov.bc.ca}.
#'
#' @seealso \code{\link[utils]{browseURL}}
#' @return A browser is opened with the B.C. Data Catalogue URL loaded if the
#'         session is interactive. The URL used is returned as a character string.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' bcdc_browse()
#' bcdc_browse("fish")
#' }
bcdc_browse <- function(query = NULL, browser = getOption("browser"),
                        encodeIfNeeded = FALSE) {

  if(!has_internet()) stop("No access to internet", call. = FALSE)

  if(is.null(query))  url <- "https://catalogue.data.gov.bc.ca"

  if(!is.null(query)){
    url <- paste0("https://catalogue.data.gov.bc.ca/dataset?q=", query)
  }

  ## Facilitates testing
  if(interactive()){
    utils::browseURL(url = url, browser = browser,
                     encodeIfNeeded = encodeIfNeeded)
  }

  invisible(url)
  }



