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

as.bcdc_sf <- function(x, query_list, url) {
  structure(x,
            class = c("bcdc_sf", setdiff(class(x), "bcdc_sf")),
            query_list = query_list,
            url = url)
}


# print methods -----------------------------------------------------------

#' @export
print.bcdc_promise <- function(x, ...) {

  query_list <- c(x$query_list, COUNT = 6)
  cli <- x$cli
  cc <- cli$get(query = query_list)
  cc$raise_for_status()

  number_of_records <- bcdc_number_wfs_records(x$query_list, x$cli)
  name <- paste0("'", x[["obj"]][["name"]], "'")
  parsed <- bcdc_read_sf(cc$parse("UTF-8"))
  fields <- ncol(parsed) - 1

  cat_line(glue::glue("Querying {col_red(name)} record"))
  cat_bullet(glue::glue("Using {col_blue('collect()')} on this object will return {col_green(number_of_records)} features ",
                 "and {col_green(fields)} fields"))
  cat_bullet("Only the first six rows of the record are printed here")
  cat_rule()
  print(parsed)


}

#' @export
print.bcdc_record <- function(x, ...) {
  cat("B.C. Data Catalogue Record:\n   ", x$title, "\n")
  cat("\nName:", x$name, "(ID:", x$id, ")")
  cat("\nPermalink:", paste0("https://catalogue.data.gov.bc.ca/dataset/", x$id))
  cat("\nSector:", x$sector)
  cat("\nLicence:", x$license_title)
  cat("\nType:", x$type)
  cat("\nLast Updated:", x$record_last_modified, "\n")
  cat("\nDescription:\n")
  cat(paste0("    ", strwrap(x$notes, width = 85), collapse = "\n"), "\n")

  cat("\nResources: (", nrow(x$resource_df), ")\n")

  for (r in seq_len(nrow(x$resource_df))) {
    record_print_helper(x$resource_df[r, ], r, print_avail = TRUE)
  }
}

record_print_helper <- function(r, n, print_avail = FALSE){
  cat(n, ") ", clean_wfs(r$name), "\n", sep = "")
  #cat("    description:", r$description, "\n")
  cat("     format:", clean_wfs(formats_from_resource(r)), "\n")
  if(r$format != "wms") cat("     url:", r$url, "\n")
  cat("     resource:", r$id, "\n")
  if (print_avail)
    cat("     available in R via bcdata: ", r$bcdata_available, "\n")
  if (r$bcdata_available)
    cat("     code: bcdc_get_data(record = '", r$package_id,
        "', resource = '",r$id,"')\n", sep = "")
  cat("\n")
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
      .y, ": ",purrr::pluck(.x, "title"),
      " (",
      paste0(unique(formats_from_record(.x)), collapse = ", "),
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
#' Filter a query from WFS using dplyr methods. This filtering is accomplished lazily so that the
#' full sf object is not read into memory until `collect()` has been called.
#'
#'
#' @param .data passed from bcdc_get_geodata
#' @param ... Logical predicates with which to filter the results. Multiple
#' conditions are combined with `&`. Only rows where the condition evaluates to
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

  if(!safe_request_length(.data$query_list)){
    stop("The vector you are trying to filter by is too long. Consider either breaking
    up the request into two or more bcdc_query_geodata() calls or using a spatial
    operator to spatial define your request. See ?cql_geom_predicates.",
    call. = FALSE)
  }

  as.bcdc_promise(list(query_list = .data$query_list, cli = .data$cli, obj = .data$obj))
}

#' Select columns from WFS call
#'
#' Similar to a `dplyr::select` call, this allows you to select which columns you want the WFS to return.
#' A key difference between `dplyr::select` and `bcdata::select` is the presence of "sticky" columns that are
#' returned regardless of what columns are selected. If any of these "sticky" columns are selected
#' only "sticky" columns are return. `bcdc_describe_feature` is one way to tell if columns are sticky in advance
#' of issuing the WFS call.
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


#' Force collection of WFS request from B.C. Data Catalogue
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
    url <- cc$url
  } else {
    message("This record requires pagination to complete the request.")
    sorting_col <- pagination_sort_col(x$obj$id)

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
    url <- cc$url_fetch(query = query_list)

    status_failed <- any(cc$status_code() >= 300)
  }

  if (status_failed) {
    ## TODO: This error message could be more informative
    stop("The BC data catalogue experienced issues with this request",
         call. = FALSE
    )
  }

  txt <- cc$parse("UTF-8")

  as.bcdc_sf(bcdc_read_sf(txt), query_list = query_list, url = url)

}


#' Show SQL and URL used for WFS request from B.C. Data Catalogue
#'
#' Display WFS query SQL
#'
#' @param x object of class bcdc_promise or bcdc_sf
#' @inheritParams show_query
#' @describeIn show_query show_query.bcdc_promise
#'
#' @export
#' @examples
#' \dontrun{
#' bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
#'   filter(PERMIT_RELATIONSHIP == "DISCHARGE") %>%
#'   show_query()
#'   }
#'
show_query.bcdc_promise <- function(x, ...) {

  url <-  x$cli$url_fetch(query = x$query_list)

  url <- url_format(url)

  cat_line("<url>")
  cat_line(url)
  cat_line()
  cat_line("<SQL>")
  cat_line(x$query_list$CQL_FILTER)

  invisible(x$cli$url_fetch(query = x$query_list))

}


#' @describeIn show_query show_query.bcdc_promise
#'
#' @export
#' @examples
#' \dontrun{
#' air <- bcdc_query_geodata("bc-airports") %>%
#'   collect()
#'
#' show_query(air)
#' }
show_query.bcdc_sf <- function(x, ...) {

  url <- url_format(attributes(x)$url)

  url <- paste0(url,"\n")

  cat_line("<url>")
  for(i in seq_along(url)){
    cat_line(glue::glue("Request {i} of {length(url)} \n{url[i]} \n"))
  }

  invisible(attributes(x)$url)

}
