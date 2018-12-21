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

#' Get the valid values for a facet (that you can use in [bcdc_search()])
#'
#' @param facet the facet for which to retrieve valid values
#'
#' @return a data frame of values for the selected facet
#' @export
#'
#' @examples
#' bcdc_facets("type")
bcdc_facets <- function(facet = c("license_id", "download_audience",
                                  "type", "res_format", "sector",
                                  "organization")) {
  facet <- match.arg(facet)
  query <- glue::glue("facet.field=[\"{facet}\"]", facet = facet)

  res <- httr::GET(paste0(base_url(), "action/package_search"), query = query)
  httr::stop_for_status(res)
  facet_list <- httr::content(res)
  purrr::map_df(facet_list$result$search_facets[[facet]]$items,
                as.data.frame,
                stringsAsFactors = FALSE)
}

#' Return a full list of the names of B.C. Data Catalogue records
#'
#' @return A character vector of the names of B.C. Data Catalogue records
#' @export
bcdc_list <- function() {
  l_new_ret <- 1
  ret <- character()
  offset <- 0
  limit <- 1000
  while (l_new_ret) {
    res <- httr::GET(paste0(base_url(), "action/package_list"),
                     query = list(offset = offset, limit = limit))
    httr::stop_for_status(res)
    new_ret <- unlist(httr::content(res)$result)
    ret <- c(ret, new_ret)
    l_new_ret <- length(new_ret)
    offset <- offset + limit
  }
  ret
}

#' Title
#'
#' @param ... search terms
#' @param license_id the type of license (see `bcdc_facets("license_id")`).
#'        Default `2` (Open Government Licence - British Columbia)
#' @param download_audience download audience
#'        (see `bcdc_facets("download_audience")`). Default `"Public"`
#' @param type type of resource (see `bcdc_facets("type")`)
#' @param res_format format of resource (see `bcdc_facets("res_format")`)
#' @param sector sector of government from which the data comes
#'        (see `bcdc_facets("sector")`)
#' @param organization government organization that manages the data
#'        (see `bcdc_facets("organization")`)
#' @param n number of results to return. Default `100`
#'
#' @return A list containing the records that match the search
#' @export
#'
#' @examples
#' bcdc_search("forest")
#' bcdc_search("regional district", type = "Geographic", res_format = "fgdb")
bcdc_search <- function(..., license_id=2,
                        download_audience="Public",
                        type = NULL,
                        res_format=NULL,
                        sector = NULL,
                        organization = NULL,
                        n = 100) {

  # TODO: allow terms to be passed as a vector, and allow use of | for OR
  terms <- paste0(compact(list(...)), collapse = "+")
  facets <- compact(list(license_id = license_id,
                download_audience = download_audience,
                type = type,
                res_format = res_format,
                sector = sector,
                organization = organization
                ))

  lapply(names(facets), function(x) {
    facet_vals <- bcdc_facets(x)
    if (!facets[x] %in% facet_vals$name) {
      stop(facets[x], " is not a valid value for ", x,
           call. = FALSE)
    }
  })

  query <- paste0(
    "q=", terms, ifelse(nzchar(terms), "+", ""),
    paste(names(facets), facets, sep = ":", collapse = "+"),
    "&rows=", n)

  query <- gsub("\\s", "%20", query)

  res <- httr::GET(paste0(base_url(), "action/package_search"),
                   query = query)

  httr::stop_for_status(res)
  cont <- httr::content(res)

  n_found <- cont$result$count
  message("Found ", n_found, " matches. Returning the first ", n,
          ".\nTo see them all, rerun the search and set the 'n' argument to ",
          n_found, ".")
  ret <- cont$result$results
  names(ret) <- vapply(ret, `[[`, "name", FUN.VALUE = character(1))
  ret <- lapply(ret, as.bcdc_record)
  as.bcdc_recordlist(ret)
}

#' Show a single B.C. Data Catalogue record
#'
#' @param id the id (name) of the record.
#'
#' @return A list containing the metadata for the record
#' @export
#'
#' @examples
#' bcdc_get_record("bc-airports")
bcdc_get_record <- function(id) {
  res <- httr::GET(paste0(base_url(), "action/package_show"),
                   query = list(id = id))
  httr::stop_for_status(res)
  ret <- httr::content(res)$result
  as.bcdc_record(ret)
}

format_record <- function(pkg) {
  pkg$details <- dplyr::bind_rows(pkg$details)
  pkg
}

as.bcdc_record <- function(x) {
  x <- format_record(x)
  class(x) <- "bcdc_record"
  x
}

as.bcdc_recordlist <- function(x) {
  class(x) <- "bcdc_recordlist"
  x
}

print.bcdc_record <- function(x) {
  cat("B.C. Data Catalogue Record:", x$title, "\n")
  cat("\nName:", x$name, "(ID:", x$id, ")")
  cat("\nPermalink:", paste0("https://catalogue.data.gov.bc.ca/dataset/", x$id))
  cat("\nSector:", x$sector)
  cat("\nLicence:", x$license_title)
  cat("\nType:", x$type, "\n")
  cat("\nDescription:\n    ", x$notes, "\n")
  cat("\nResources: (", length(x$resources), ")\n")
  for (i in seq_along(x$resources)) {
    r <- x$resources[[i]]
    cat("  ", i, ": ", r$name, "\n", sep = "")
    cat("    description:", r$description, "\n")
    cat("    format:", r$format, "\n")
    cat("    access:", r$resource_storage_access_method, "\n")
    cat("    access_url:", r$url, "\n")
  }
}

print.bcdc_recordlist <- function(x) {
  cat("List of B.C. Data Catalogue Records\n")
  cat("\nNumber:", length(x), ". Showing the top 10.")
  cat("\nTitles:\n")
  x <- purrr::set_names(x, NULL)
  cat(paste(purrr::imap(x[1:10], ~ {
    paste0(.y, ": ", .x[["title"]])
  }), collapse = "\n"), "\n")
  cat("\nAccess a single record by indexing the record list by its number")
}
