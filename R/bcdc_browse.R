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
#' @param url a non-empty character string giving the URL to be loaded. Default \code{https://catalogue.data.gov.bc.ca}.
#'
#' @seealso \code{\link[utils]{browseURL}}
#' @return A browser is opened with the B.C. Data Catalogue URL loaded: nothing is returned to the R interpreter
#'
#' @export
#'
#' @examples
#' \dontrun{
#' bcdc_browse()
#' }
bcdc_browse <- function(url = "https://catalogue.data.gov.bc.ca", browser = getOption("browser"),
                        encodeIfNeeded = FALSE) {

  if(!has_internet()) stop("No access to internet", call. = FALSE)

  utils::browseURL(url = url, browser = browser,
            encodeIfNeeded = encodeIfNeeded)
  }



