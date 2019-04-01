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

#' @export
print.bcdc_promise <- function(x, ...) {

  query_list <- c(x$query_list, COUNT = 10)
  cli <- x$cli
  cc <- cli$get(query = query_list)
  cc$raise_for_status()

  txt <- cc$parse("UTF-8")
  print(bcdc_read_sf(txt))
}


#' filter methods
#'
#' @param .data passed from bcdc_get_geodata
#' @param ... Logical predicates with which to filter the results. Multiple
#' conditions are combined with `&`. Only rows where the condition evalueates to
#' `TRUE` are kept. Accepts normal R expressions as well as any of the special
#' [CQL geometry functions][cql_geom_predicates] such as `WITHIN()` or `INTERSECTS()`.
#' If you know `CQL` and want to write a `CQL` query directly, write it enclosed
#' in quotes, wrapped in the [CQL()] function. e.g., `CQL("ID = '42'")`
#' @export
filter.bcdc_promise <- function(.data, ...) {

  .data$query_list$CQL_FILTER <- cql_translate(...)

  as.bcdc_promise(list(query_list = .data$query_list, cli = .data$cli, obj = .data$obj))
}


#' Force collection of WFS request from BC Data Catalogue
#'
#' Retrieve an sf object from data catalogue.
#'
#' @param x object of class bcdc_promise
#' @inheritParams collect
#' @describeIn collect collect.bcdc_promise
#' @export
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
