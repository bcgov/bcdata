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
#' @param query Default (NULL) opens a browser to \code{https://catalogue.data.gov.bc.ca}.
#'        This argument will also accept a B.C. Data Catalogue record ID or name to take you
#'        directly to that page. If the provided ID or name doesn't lead to a valid webpage,
#'        bcdc_browse will search the data catalogue for that string.
#'
#' @seealso \code{\link[utils]{browseURL}}
#' @return A browser is opened with the B.C. Data Catalogue URL loaded if the
#'         session is interactive. The URL used is returned as a character string.
#'
#' @export
#'
#' @examples
#' \donttest{
#' ## Take me to the B.C. Data Catalogue home page
#' try(
#'   bcdc_browse()
#' )
#'
#' ## Take me to the B.C. airports catalogue record
#' try(
#'  bcdc_browse("bc-airports")
#' )
#'
#' ## Take me to the B.C. airports catalogue record
#' try(
#'   bcdc_browse("76b1b7a3-2112-4444-857a-afccf7b20da8")
#' )
#'
#' ## Take me to the catalogue search results for 'fish'
#' try(
#'  bcdc_browse("fish")
#' )
#'
#' }
bcdc_browse <- function(query = NULL, browser = getOption("browser"),
                        encodeIfNeeded = FALSE) {
  if(!has_internet()) stop("No access to internet", call. = FALSE) # nocov

  base_url <- catalogue_base_url()

  if (is.null(query))  {
    url <- base_url
  } else {

    ## Check if the record is valid, if not return a query.
    # Need to check via HEAD request to the api as the catalogue
    # doesn't return a 404 status code.
    cli <- bcdc_catalogue_client("action/package_show")
    res <- cli$head(query = list(id = query))

    if(res$status_code == 404){
      stop("The specified record does not exist in the catalogue")
      ## NB - previous version would show a catalogue search in the
      ## browser, but with new catalogue it doesn't seem possible
      ## to set a browser-based catalogue search via url query parameters
      # url <- paste0(make_url(base_url, "dataset"),
      #               "?q=", query)
    }

    url <- make_url(catalogue_base_url(), "dataset", query)
  }

  ## Facilitates testing
  if(interactive()){
    # nocov start
    utils::browseURL(url = url, browser = browser,
                     encodeIfNeeded = encodeIfNeeded)
    # nocov end
  }

  invisible(url)
}



