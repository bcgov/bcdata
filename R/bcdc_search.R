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
#' @param facet the facet(s) for which to retrieve valid values. Can be one or
#' more of:
#'  `"license_id", "download_audience", "res_format", "sector", "organization", "groups"`
#'
#' @return A data frame of values for the selected facet
#' @export
#'
#' @examples
#' \donttest{
#' try(
#'   bcdc_search_facets("download_audience")
#' )
#'
#' try(
#'   bcdc_search_facets("res_format")
#' )
#' }
bcdc_search_facets <- function(facet = c("license_id", "download_audience",
                                  "res_format", "sector",
                                  "organization", "groups")) {
  if(!has_internet()) stop("No access to internet", call. = FALSE) # nocov

  facet <- match.arg(facet, several.ok = TRUE)
  query <- paste0("\"", facet, "\"", collapse = ",")
  query <- paste0("[", query, "]")

  cli <- bcdc_catalogue_client("action/package_search")

  r <- cli$get(query = list(facet.field = query, rows = 0))
  r$raise_for_status()

  res <- jsonlite::fromJSON(r$parse("UTF-8"))
  stopifnot(res$success)

  facet_list <- res$result$search_facets

  facet_dfs <- lapply(facet_list, function(x) {
    x$items$facet <- x$title
    x$items[, c("facet", setdiff(names(x$items), "facet"))]
    }
  )

  dplyr::bind_rows(facet_dfs)

}

#' @export
#' @describeIn bcdc_list_group_records
#'
bcdc_list_groups <- function() bcdc_search_facets("groups")

#' Retrieve group information for B.C. Data Catalogue
#'
#' Returns a tibble of groups or records. Groups can be viewed here:
#' https://catalogue.data.gov.bc.ca/group or accessed directly from R using `bcdc_list_groups`
#'
#' @param group Name of the group
#' @export
#' @examples
#' \donttest{
#' try(
#'   bcdc_list_group_records('environmental-reporting-bc')
#' )
#' }

bcdc_list_group_records <- function(group) {
  if(!has_internet()) stop("No access to internet", call. = FALSE) # nocov

  cli <- bcdc_catalogue_client("action/group_show")

  r <- cli$get(query = list(id = group, include_datasets = 'true'))

  if (r$status_code == 404){
    stop("404: URL not found - you may have specified an invalid group?", call. = FALSE)
  }

  r$raise_for_status()

  res <- jsonlite::fromJSON(r$parse("UTF-8"))
  stopifnot(res$success)

  d <- tibble::as_tibble(res$result$packages)
  as.bcdc_group(d, description = res$result$description)

}

#' @export
#' @describeIn bcdc_list_organization_records
#'
bcdc_list_organizations <- function() bcdc_search_facets("organization")

#' Retrieve organization information for B.C. Data Catalogue
#'
#' Returns a tibble of organizations or records. Organizations can be viewed here:
#' https://catalogue.data.gov.bc.ca/organizations or accessed directly from R using `bcdc_list_organizations`
#'
#' @param organization Name of the organization
#' @export
#' @examples
#' \donttest{
#' try(
#'   bcdc_list_organization_records('bc-stats')
#' )
#' }

bcdc_list_organization_records <- function(organization) {
  if(!has_internet()) stop("No access to internet", call. = FALSE) # nocov

  cli <- bcdc_catalogue_client("action/organization_show")

  r <- cli$get(query = list(id = organization, include_datasets = 'true'))

  if (r$status_code == 404){
    stop("404: URL not found - you may have specified an invalid organization?",  call. = FALSE)
  }

  r$raise_for_status()

  res <- jsonlite::fromJSON(r$parse("UTF-8"))
  stopifnot(res$success)

  d <- tibble::as_tibble(res$result$packages)
  as.bcdc_organization(d, description = res$result$description)

}

#' Return a full list of the names of B.C. Data Catalogue records
#'
#' @return A character vector of the names of B.C. Data Catalogue records
#' @export
#' @examples
#' \donttest{
#' try(
#'   bcdc_list()
#' )
#' }
bcdc_list <- function() {
  if(!has_internet()) stop("No access to internet", call. = FALSE) # nocov

  l_new_ret <- 1
  ret <- character()
  offset <- 0
  limit <- 1000
  while (l_new_ret) {

    cli <- bcdc_catalogue_client("action/package_list")

    r <- cli$get(query = list(offset = offset, limit = limit))
    r$raise_for_status()

    res <- jsonlite::fromJSON(r$parse("UTF-8"))
    stopifnot(res$success)

    new_ret <- unlist(res$result)
    ret <- c(ret, new_ret)
    l_new_ret <- length(new_ret)
    offset <- offset + limit
  }
  ret
}

#' Search the B.C. Data Catalogue
#'
#' @param ... search terms
#' @param license_id the type of license (see `bcdc_search_facets("license_id")`).
#' @param download_audience download audience
#'        (see `bcdc_search_facets("download_audience")`). Default `NULL` (all audiences).
#' @param res_format format of resource (see `bcdc_search_facets("res_format")`)
#' @param sector sector of government from which the data comes
#'        (see `bcdc_search_facets("sector")`)
#' @param organization government organization that manages the data
#'        (see `bcdc_search_facets("organization")`)
#' @param groups collections of datasets for a particular project or on a particular theme
#'        (see `bcdc_search_facets("groups")`)
#' @param n number of results to return. Default `100`
#'
#' @return A list containing the records that match the search
#' @export
#'
#' @examples
#' \donttest{
#' try(
#'   bcdc_search("forest")
#' )
#'
#' try(
#'   bcdc_search("regional district", res_format = "fgdb")
#' )
#'
#' try(
#'   bcdc_search("angling", groups = "bc-tourism")
#' )
#' }
bcdc_search <- function(..., license_id = NULL,
                        download_audience = NULL,
                        res_format = NULL,
                        sector = NULL,
                        organization = NULL,
                        groups = NULL,
                        n = 100) {

  if (!has_internet()) stop("No access to internet", call. = FALSE) # nocov

  # TODO: allow terms to be passed as a vector, and allow use of | for OR
  terms <- process_search_terms(...)

  facets <- compact(list(license_id = license_id,
                download_audience = download_audience,
                res_format = res_format,
                sector = sector,
                organization = organization,
                groups = groups
                ))

  # build query by collating the terms and any user supplied facets
  # if there are no supplied facets (e.g., is_empty(facets) returns TRUE) just use terms)
  query <- if (is_empty(facets)) {
    paste0(terms)
  } else {
    #check that the facet values are valid
    lapply(names(facets), function(x) {
      facet_vals <- bcdc_search_facets(x)
      if (!facets[x] %in% facet_vals$name) {
        stop(facets[x], " is not a valid value for ", x,
             call. = FALSE)
      }
    })

    paste0(terms, "+", paste(
      names(facets),
      paste0("\"", facets, "\""),
      sep = ":",
      collapse = "+"
    ))
  }

  query <- gsub("\\s+", "%20", query)

  cli <- bcdc_catalogue_client("action/package_search")

  # Use I(query) to treat query as is, so that things like + and :
  # aren't encoded as %2B, %3A etc
  r <- cli$get(query = list(q = I(query), rows = n))
  r$raise_for_status

  res <- jsonlite::fromJSON(r$parse("UTF-8"), simplifyVector = FALSE)
  stopifnot(res$success)

  cont <- res$result

  n_found <- cont$count
  if(n_found > n){
    message("Found ", n_found, " matches. Returning the first ", n,
            ".\nTo see them all, rerun the search and set the 'n' argument to ",
            n_found, ".")
  }
  ret <- cont$results
  names(ret) <- vapply(ret, `[[`, "name", FUN.VALUE = character(1))
  ret <- lapply(ret, as.bcdc_record)
  as.bcdc_recordlist(ret)
}

#' Show a single B.C. Data Catalogue record
#'
#' @param id the human-readable name, permalink ID, or
#' URL of the record.
#'
#' It is advised to use the permanent ID for a record rather than the
#' human-readable name to guard against future name changes of the record.
#' If you use the human-readable name a warning will be issued once per
#' session. You can silence these warnings altogether by setting an option:
#' `options("silence_named_get_record_warning" = TRUE)` - which you can put
#' in your .Rprofile file so the option persists across sessions.
#'
#' @return A list containing the metadata for the record
#' @export
#'
#' @examples
#' \donttest{
#' try(
#'   bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/bc-airports")
#' )
#'
#' try(
#'   bcdc_get_record("bc-airports")
#' )
#'
#' try(
#'   bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8")
#' )
#'
#' try(
#'   bcdc_get_record("76b1b7a3-2112-4444-857a-afccf7b20da8")
#' )
#' }
bcdc_get_record <- function(id) {

  if(!has_internet()) stop("No access to internet", call. = FALSE) # nocov

  id <- slug_from_url(id)

  cli <- bcdc_catalogue_client("action/package_show")

  r <- cli$get(query = list(id = id))

  if (r$status_code == 404){
    stop(paste0("'", id, "' is not a valid record id or name in the B.C. Data Catalogue"), call. = FALSE)
  }

  r$raise_for_status()

  res <- jsonlite::fromJSON(r$parse("UTF-8"), simplifyVector = FALSE)
  stopifnot(res$success)

  ret <- res$result

  if (ret$id != id) {
    get_record_warn_once(
      "It is advised to use the permanent id ('", ret$id, "') ",
      "rather than the name of the record ('", id,
      "') to guard against future name changes.\n"
    )
  }

  as.bcdc_record(ret)
}

format_record <- function(pkg) {
  # Create a resources data frame
  res_df <- resource_to_tibble(pkg$resources)
  pkg$resource_df <- res_df
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

as.bcdc_group <- function(x, description) {
  structure(x,
            class = c("bcdc_group", setdiff(class(x), "bcdc_group")),
            description = description)
}

as.bcdc_organization <- function(x, description) {
  structure(x,
            class = c("bcdc_organization", setdiff(class(x), "bcdc_organization")),
            description = description)
}

#' Provide a data frame containing the metadata for all resources from a single B.C. Data Catalogue record
#'
#' Returns a rectangular data frame of all resources contained within a record. This is particularly useful
#' if you are trying to construct a vector of multiple resources in a record. The data frame also provides
#' useful information on the formats, availability and types of data available.
#'
#' @inheritParams bcdc_get_data
#'
#'
#' @return A data frame containing the metadata for all the resources for a record
#'
#' @examples
#' \donttest{
#' try(
#'   airports <- bcdc_get_record("bc-airports")
#' )
#'
#' try(
#'   bcdc_tidy_resources(airports)
#' )
#' }
#'
#' @export
bcdc_tidy_resources <- function(record){
  if (!has_internet()) stop("No access to internet", call. = FALSE) # nocov
  UseMethod("bcdc_tidy_resources")
}


#' @export
bcdc_tidy_resources.default <- function(record) {
  stop("No bcdc_tidy_resources method for an object of class ", class(record),
       call. = FALSE)
}


#' @export
bcdc_tidy_resources.character <- function(record){

  if (is_whse_object_name(record)) {
    stop("No bcdc_tidy_resources method for a BCGW object name", call. = FALSE)
  }

  bcdc_tidy_resources(bcdc_get_record(record))
}


#' @export
bcdc_tidy_resources.bcdc_record <- function(record) {
  record$resource_df
}

process_search_terms <- function(...) {
  dots_list <- compact(list(...))
  if (length(names(dots_list)) > 0) {
    stop("search terms passed to ... should not be named")
  }
  paste0(dots_list, collapse = "+")
}
