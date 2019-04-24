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

## Add "bcdc_promise" class
as.bcdc_promise <- function(res) {
  structure(res,
            class = c("bcdc_promise", setdiff(class(res), "bcdc_promise"))
  )
}


# print methods -----------------------------------------------------------

#' @export
print.bcdc_promise <- function(x, ...) {

  id <- x[["obj"]][["id"]]

  feature_spec <- bcdc_describe_feature(id)

  if(!is.null(x[["query_list"]][["propertyName"]])){
    selectables <- unlist(strsplit(x[["query_list"]][["propertyName"]],","))
    feature_spec <- feature_spec[feature_spec$selectable == FALSE | feature_spec$col_name %in% selectables,]
    geom_row <- dplyr::tibble(col_name = "geometry",
                              selectable = TRUE,
                              remote_col_type = "gml:GeometryPropertyType",
                              local_col_type = wfs_to_r_col_type("gml:GeometryPropertyType"))
    feature_spec <- dplyr::bind_rows(feature_spec, geom_row)
  }

  number_of_records <- bcdc_number_wfs_records(x$query_list, x$cli)

  cat(glue::glue("# A BC Data Catalogue Record: {number_of_records} records\n\n"))
  print(feature_spec, n = Inf)

}

#' @export
print.bcdc_record <- function(x, ...) {
  cat("B.C. Data Catalogue Record:\n   ", x$title, "\n")
  cat("\nName:", x$name, "(ID:", x$id, ")")
  cat("\nPermalink:", paste0("https://catalogue.data.gov.bc.ca/dataset/", x$id))
  cat("\nSector:", x$sector)
  cat("\nLicence:", x$license_title)
  cat("\nType:", x$type, "\n")
  cat("\nDescription:\n")
  cat(paste0("    ", strwrap(x$notes, width = 85), collapse = "\n"), "\n")

  record_formats <- tools::file_ext(purrr::map_chr(x$resources, ~ purrr::pluck(.x, "url")))

  if ("wms" %in% record_formats) {
    x$resources[record_formats == "kml"] <- NULL
  }

  cat("\nResources: (", length(x$resources), ")\n")
  purrr::walk(x$resources, record_print_helper)
}

#' @export
print.bcdc_recordlist <- function(x, ...) {
  cat("List of B.C. Data Catalogue Records\n")
  len <- length(x)
  n_print <- min(10, len)
  cat("\nNumber of records:", len)
  if (n_print < len) cat(" (Showing the top 10)")
  cat("\nTitles:\n")
  x <- purrr::set_names(x, NULL)
  cat(paste(purrr::imap(x[1:n_print], ~ {
    paste0(
      .y, ": ",
      purrr::pluck(.x, "title"),
      " (",
      paste0(
        file_ext_with_other(purrr::map_chr(purrr::pluck(.x, "resources"), purrr::pluck, "url")),
        collapse = ","
      ),
      ")",
      "\n ID: ", purrr::pluck(.x, "id"),
      "\n Name: ", purrr::pluck(.x, "name")
    )
  }), collapse = "\n"), "\n")
  cat("\nAccess a single record by calling bcdc_get_record(ID)
      with the ID from the desired record.")
}



# dplyr methods -----------------------------------------------------------


#' filter methods
#'
#' Filter a query from wfs using dplyr methods. This filtering is accomplished lazily so that the
#' full sf object is not read into memory until `collect()` has been called.
#'
#'
#' @param .data passed from bcdc_get_geodata
#' @param ... Logical predicates with which to filter the results. Multiple
#' conditions are combined with `&`. Only rows where the condition evalueates to
#' `TRUE` are kept. Accepts normal R expressions as well as any of the special
#' [CQL geometry functions][cql_geom_predicates] such as `WITHIN()` or `INTERSECTS()`.
#' If you know `CQL` and want to write a `CQL` query directly, write it enclosed
#' in quotes, wrapped in the [CQL()] function. e.g., `CQL("ID = '42'")`
#'
#' @examples
#' \dontrun{
#'   crd <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
#'     filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
#'     collect()
#'
#' ret1 <- bcdc_query_geodata("fire-perimeters-historical") %>%
#'   filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
#'   collect()
#'   }
#' @export
filter.bcdc_promise <- function(.data, ...) {

  .data$query_list$CQL_FILTER <- cql_translate(...)

  ## Change CQL query on the fly if geom is not GEOMETRY
  .data$query_list$CQL_FILTER <- specify_geom_name(.data$obj, .data$query_list)

  as.bcdc_promise(list(query_list = .data$query_list, cli = .data$cli, obj = .data$obj))
}

#' select columns from wfs call
#'
#' Similar to a `dplyr::select` call, this allows you to select which columns you want the wfs to return.
#' A key difference between `dplyr::select` and `bcdata::select` is the presence of "sticky" columns that are
#' returned regardless of what columns are selected. If any of these "sticky" columns are selected
#' only "sticky" columns are returns. `bcdc_describe_feature` is one way to tell if columns are stick in advance
#' of issuing the wfs call.
#'
#' @param .data passed from bcdc_get_geodata
#' @param ... One or more unquoted expressions separated by commas. See details.
#'
#' @examples
#' \dontrun{
#' feature_spec <- bcdc_describe_feature("bc-airports")
#' ## Columns that can selected:
#' feature_spec[feature_spec$nillable == TRUE,]
#'
#' ## Select columns
#' bcdc_query_geodata("bc-airports") %>%
#'   select(DESCRIPTION, PHYSICAL_ADDRESS)
#'
#' ## Select "sticky" columns
#' bcdc_query_geodata("bc-airports") %>%
#'   select(LOCALITY)
#' }
#'
#'@export
select.bcdc_promise <- function(.data, ...){
  dots <- rlang::exprs(...)

  ## Always add back in the geom
  cols_to_select <- paste(geom_col_name(.data$obj), paste0(dots, collapse = ","), sep = ",")

  query_list <- c(.data$query_list, propertyName = cols_to_select)

  as.bcdc_promise(list(query_list = query_list, cli = .data$cli, obj = .data$obj))

}


#' Force collection of WFS request from BC Data Catalogue
#'
#' After tuning a query, `collect()` is used to actually bring the data into memory.
#' This will retrieve an sf object into R.
#'
#' @param x object of class bcdc_promise
#' @inheritParams collect
#' @describeIn collect collect.bcdc_promise
#' @export
#'
#' @examples
#' \dontrun{
#' bcdc_query_geodata("bc-airports") %>%
#'   collect()
#' }
#'
collect.bcdc_promise <- function(x, ...){

  query_list <- x$query_list
  cli <- x$cli

  ## Determine total number of records for pagination purposes
  number_of_records <- bcdc_number_wfs_records(query_list, cli)

  if (number_of_records < 10000) {
    cc <- cli$get(query = query_list)
    status_failed <- cc$status_code >= 300
  } else {
    message("This record requires pagination to complete the request.")
    sorting_col <- x$obj[["details"]][["column_name"]][1]

    query_list <- c(query_list, sortby = sorting_col)

    # Create pagination client
    cc <- crul::Paginator$new(
      client = cli,
      by = "query_params",
      limit_param = "count",
      offset_param = "startIndex",
      limit = number_of_records,
      limit_chunk = 5000,
      progress = TRUE
    )


    message("Retrieving data")
    cc$get(query = query_list)

    status_failed <- any(cc$status_code() >= 300)
  }

  if (status_failed) {
    ## TODO: This error message could be more informative
    stop("The BC data catalogue experienced issues with this request",
         call. = FALSE
    )
  }

  txt <- cc$parse("UTF-8")

  bcdc_read_sf(txt)

}


#' Show SQL and URL used for WFS request from BC Data Catalogue
#'
#' Display WFS query SQL
#'
#' @param x object of class bcdc_promise
#' @inheritParams show_query
#' @describeIn show_query show_query.bcdc_promise
#'
#' @export
#' @examples
#' bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
#'   filter(PERMIT_RELATIONSHIP == "DISCHARGE") %>%
#'   show_query()
show_query.bcdc_promise <- function(x, ...){

  query_list <- x$query_list

  query_list$CQL_FILTER <- NULL

  ## Drop any NULLS from the list
  query_list <- compact(query_list)

  url_params <- paste0(names(query_list),"=", query_list, collapse = "&\n")
  url_params <- gsub(":", "%3A", url_params)
  url_params <- gsub("/", "%2F", url_params)

  url_query <- paste0("<url> \n", x$cli$url,"?\n", url_params, "\n")

  cat(url_query)
  cat(paste0("<SQL> \n", x$query_list$CQL_FILTER))
}

