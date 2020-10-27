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

as.bcdc_sf <- function(x, query_list, url, full_url) {
  structure(x,
            class = c("bcdc_sf", setdiff(class(x), "bcdc_sf")),
            query_list = query_list,
            url = url, full_url = full_url, time_downloaded = Sys.time())
}


as.bcdc_query <- function(x) {
  structure(x,
            class = c("bcdc_query", setdiff(class(x), "bcdc_query"))
  )
}


# print methods -----------------------------------------------------------

#' @export
print.bcdc_promise <- function(x, ...) {

  x$query_list$CQL_FILTER <- finalize_cql(x$query_list$CQL_FILTER)

  if (is.null(x$query_list$count)) {
    query_list <- c(x$query_list, count = 6) ## only add if not there.
  } else {
   query_list <- x$query_list
  }

  cli <- x$cli
  cc <- cli$post(body = query_list, encode = "form")

  catch_wfs_error(cc)

  number_of_records <- bcdc_number_wfs_records(x$query_list, x$cli)

  if (!is.null(x$query_list$count)) {
    # head or tail have updated the count
    number_of_records <- x$query_list$count
  }

  parsed <- bcdc_read_sf(cc$parse("UTF-8"))
  fields <- ncol(parsed) - 1

  # Check if this was called using a whse name directly without going
  # through a catalogue record so don't have this info
  name <- ifelse(is_record(x$record),
                 paste0("'", x[["record"]][["name"]], "'"),
                 paste0("'", x[["query_list"]][["typeNames"]], "'"))
  cat_line_wrap(glue::glue("Querying {col_red(name)} record"))

  cat_bullet(strwrap(glue::glue("Using {col_blue('collect()')} on this object will return {col_green(number_of_records)} features ",
                        "and {col_green(fields)} fields")))
  cat_bullet(strwrap("At most six rows of the record are printed here"))
  cat_rule()
  print(parsed)
  invisible(x)
}

#' @export
print.bcdc_record <- function(x, ...) {
  cat_line_wrap(cli::col_blue(cli::style_bold("B.C. Data Catalogue Record: ")), x$title)
  cat_line_wrap(cli::col_blue(cli::style_italic("Name: ")), x$name, " (ID: ", x$id, ")")
  cat_line_wrap(cli::col_blue(cli::style_italic("Permalink: ")), paste0("https://catalogue.data.gov.bc.ca/dataset/", x$id))
  cat_line_wrap(cli::col_blue(cli::style_italic("Sector: ")), x$sector)
  cat_line_wrap(cli::col_blue(cli::style_italic("Licence: ")), x$license_title)
  cat_line_wrap(cli::col_blue(cli::style_italic("Type: ")), x$type)
  cat_line_wrap(cli::col_blue(cli::style_italic("Last Updated: ")), x$record_last_modified)
  cat_line_wrap(cli::col_blue(cli::style_italic("Description: ")), x$notes)

  cat_line_wrap(cli::col_blue(cli::style_italic("Resources: (", nrow(bcdc_tidy_resources(x)), ")")))
  print(bcdc_tidy_resources(x))

  cat_line_wrap(cli::col_blue("You can access the 'Resources' data frame using bcdc_tidy_resources()"))

  invisible(x)
}

record_print_helper <- function(r, n, print_avail = FALSE) {
  cat_line_wrap(n, ") ", clean_wfs(r$name))
  #cat_line_wrap("    description:", r$description)
  cat_line_wrap("format: ", clean_wfs(formats_from_resource(r)), indent = 3)
  if (r$format != "wms") cat_line_wrap("url: ", r$url, indent = 3)
  cat_line_wrap("resource: ", r$id, indent = 3)
  if (print_avail) {
    cat_line_wrap("available in R via bcdata: ",
        if (r$format == "zip") {
          "Will attempt - unknown format (zipped)"
        } else {
          r$bcdata_available
        })
  }
  if (r$bcdata_available)
    cat_line_wrap("code: ", "bcdc_get_data(record = '", r$package_id,
        "', resource = '",r$id,"')", indent = 3)
  cat_line()
}

#' @export
print.bcdc_recordlist <- function(x, ...) {
  cat_line_wrap("List of B.C. Data Catalogue Records")
  len <- length(x)
  n_print <- min(10, len)
  cat_line_wrap("Number of records: ", len)
  if (n_print < len) cat_line(" (Showing the top 10)")
  cat_line_wrap("Titles:")
  x <- purrr::set_names(x, NULL)

  purrr::imap(x[1:n_print], ~ {

    if (!nrow(bcdc_tidy_resources(x[[.y]]))) {
      cat_line_wrap(.y, ": ",purrr::pluck(.x, "title"))
      cat_line_wrap("This record has no resources. bcdata will not be able to access any data.", col = "red")
    } else {
      cat_line_wrap(.y, ": ",purrr::pluck(.x, "title"),
                    " (", paste0(unique(formats_from_record(.x)), collapse = ", "),
                    ")")
    }

    cat_line_wrap("ID: ", purrr::pluck(.x, "id"), indent = 1, exdent = 2)
    cat_line_wrap("Name: ", purrr::pluck(.x, "name"), indent = 1, exdent = 2)
  })

  cat_line()
  cat_line_wrap("Access a single record by calling `bcdc_get_record(ID)`
      with the ID from the desired record.")
  invisible(x)
}

#' @export
print.bcdc_query <- function(x, ...) {

  cat_line("<url>")
  if (length(x$url) > 1) {
    for (i in seq_along(x$url)) {
      cat_line_wrap(glue::glue("Request {i} of {length(x$url)} \n{x$url[i]}"))
    }
  }

  cat_line("<body>")
  cat_line_wrap(glue::glue("   {names(x$query_list)}: {x$query_list}"))
  cat_line()
  cat_line("<full query url>")
  cat_line_wrap(x$full_url)
  invisible(x)
}


# dplyr methods -----------------------------------------------------------


#' Filter a query from Web Service call
#'
#' Filter a query from Web Service using dplyr methods. This filtering is accomplished lazily so that the
#' full sf object is not read into memory until `collect()` has been called.
#'
#' @param .data object of class `bcdc_promise` (likely passed from [bcdc_query_geodata()])
#' @param ... Logical predicates with which to filter the results. Multiple
#' conditions are combined with `&`. Only rows where the condition evaluates to
#' `TRUE` are kept. Accepts normal R expressions as well as any of the special
#' [CQL geometry functions][cql_geom_predicates] such as `WITHIN()` or `INTERSECTS()`.
#' If you know `CQL` and want to write a `CQL` query directly, write it enclosed
#' in quotes, wrapped in the [CQL()] function. e.g., `CQL("ID = '42'")`
#'
#' @describeIn filter filter.bcdc_promise
#' @examples
#' \donttest{
#' try(
#'   crd <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
#'     filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
#'     collect()
#' )
#'
#' try(
#'   ret1 <- bcdc_query_geodata("fire-perimeters-historical") %>%
#'     filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
#'     collect()
#' )
#'   }
#' @export
filter.bcdc_promise <- function(.data, ...) {

  current_cql = cql_translate(...)
  ## Change CQL query on the fly if geom is not GEOMETRY
  current_cql = specify_geom_name(.data$cols_df, current_cql)

  # Add cql filter statement to any existing cql filter statements.
  # ensure .data$query_list$CQL_FILTER is class sql even if NULL, so
  # dispatches on sql class and dbplyr::c.sql method is used
  .data$query_list$CQL_FILTER <- c(dbplyr::sql(.data$query_list$CQL_FILTER),
                                   current_cql,
                                   drop_null = TRUE)

  as.bcdc_promise(list(query_list = .data$query_list, cli = .data$cli,
                       record = .data$record, cols_df = .data$cols_df))
}

#' Select columns from Web Service call
#'
#' Similar to a `dplyr::select` call, this allows you to select which columns you want the Web Service to return.
#' A key difference between `dplyr::select` and `bcdata::select` is the presence of "sticky" columns that are
#' returned regardless of what columns are selected. If any of these "sticky" columns are selected
#' only "sticky" columns are return. `bcdc_describe_feature` is one way to tell if columns are sticky in advance
#' of issuing the Web Service call.
#'
#' @param .data object of class `bcdc_promise` (likely passed from [bcdc_query_geodata()])
#' @param ... One or more unquoted expressions separated by commas. See details.
#'
#' @describeIn select select.bcdc_promise
#'
#' @examples
#' \donttest{
#' try(
#'   feature_spec <- bcdc_describe_feature("bc-airports")
#' )
#'
#' try(
#'   ## Columns that can selected:
#'   feature_spec[feature_spec$sticky == TRUE,]
#' )
#'
#' ## Select columns
#' try(
#'   bcdc_query_geodata("bc-airports") %>%
#'     select(DESCRIPTION, PHYSICAL_ADDRESS)
#' )
#'
#' ## Select "sticky" columns
#' try(
#'   bcdc_query_geodata("bc-airports") %>%
#'     select(LOCALITY)
#' )
#' }
#'
#'
#'@export
select.bcdc_promise <- function(.data, ...){

  ## Eventually have to migrate to tidyselect::eval_select
  ## https://community.rstudio.com/t/evaluating-using-rlang-when-supplying-a-vector/44693/10
  cols_to_select <- tidyselect::vars_select(.data$cols_df$col_name, ...)

  ## id is always added in. web request doesn't like asking for it twice
  cols_to_select <- remove_id_col(cols_to_select)
  ## Always add back in the geom
  cols_to_select <- paste(geom_col_name(.data$cols_df), paste0(cols_to_select, collapse = ","), sep = ",")

  query_list <- c(.data$query_list, propertyName = cols_to_select)

  as.bcdc_promise(list(query_list = query_list, cli = .data$cli,
                       record = .data$record, cols_df = .data$cols_df))

}

#' @importFrom utils head
#' @export
head.bcdc_promise <- function(x, n = 6L, ...) {
  sorting_col <- pagination_sort_col(x$cols_df)
  x$query_list <- c(
    x$query_list,
    count = n,
    sortBy = sorting_col
  )
  x
}

#' @importFrom utils tail
#' @export
tail.bcdc_promise <- function(x, n = 6L, ...) {
  number_of_records <- bcdc_number_wfs_records(x$query_list, x$cli)
  sorting_col <- pagination_sort_col(x$cols_df)
  x$query_list <- c(
    x$query_list,
    count = n,
    sortBy = sorting_col,
    startIndex = number_of_records - n
  )
  x
}


#' Throw an informative error when attempting mutate on a Web Service call
#'
#' The CQL syntax to generate WFS calls does not current allow arithmetic operations. Therefore
#' this function exists solely to generate an informative error that suggests an alternative
#' approach to use mutate with bcdata
#'
#' @param .data object of class `bcdc_promise` (likely passed from [bcdc_query_geodata()])
#' @param ... One or more unquoted expressions separated by commas. See details.
#' @describeIn mutate mutate.bcdc_promise
#' @examples
#' \dontrun{
#'
#' ## Mutate columns
#' try(
#'   bcdc_query_geodata("bc-airports") %>%
#'     mutate(LATITUDE * 100)
#' )
#' }
#'
#'@export
mutate.bcdc_promise <- function(.data, ...){
  dots <- rlang::exprs(...)

  stop(glue::glue(
    "You must type collect() before using mutate() on a WFS. \nAfter using collect() add this mutate call::
    mutate({dots}) "), call. = FALSE)
}

collect_bcdc_promise_ <- function(x, ...){
  check_chunk_limit()

  x$query_list$CQL_FILTER <- finalize_cql(x$query_list$CQL_FILTER)

  query_list <- x$query_list
  cli <- x$cli

  ## Determine total number of records for pagination purposes
  number_of_records <- bcdc_number_wfs_records(query_list, cli)

  if (number_of_records < 10000) {
    cc <- tryCatch(cli$post(body = query_list, encode = "form"),
                   error = function(e) {
                     stop("There was an issue processing this request.
                     Try reducing the size of the object you are trying to retrieve.", call. = FALSE)})

    catch_wfs_error(cc)
    url <- cc$url
    full_url <- cli$url_fetch(query = query_list)
  } else {
    # tests that cover this are skipped due to large size
    # nocov start
    message("This record requires pagination to complete the request.")
    sorting_col <- pagination_sort_col(x$cols_df)

    query_list <- c(query_list, sortby = sorting_col)

    # Create pagination client
    cc <- crul::Paginator$new(
      client = cli,
      by = "query_params",
      limit_param = "count",
      offset_param = "startIndex",
      limit = number_of_records,
      limit_chunk = getOption("bcdata.chunk-limit", default = 1000),
      progress = TRUE
    )


    message("Retrieving data")

    tryCatch(cc$post(body = query_list, encode = "form"),
             error = function(e) {
               stop("There was an issue processing this request.
                     Try reducing the size of the object you are trying to retrieve.", call. = FALSE)})

    url <- cc$url
    full_url <- cc$url_fetch(query = query_list)

    catch_wfs_error(cc)
    # nocov end
  }

  txt <- cc$parse("UTF-8")

  ret <- as.bcdc_sf(bcdc_read_sf(txt), query_list = query_list, url = url,
             full_url = full_url)

  if (getOption("bcdata.cache_verbose", FALSE)) {
    message("caching for ", bcdc_cache_timeout(),
            " seconds at ", bcdc_cache_path())
  }

  ret

}

#' Retrieve Default Cache timeout
#'
#' Retrieves the length of time that a cache of [collect()]ed
#' web resources is kept. Default is 1 hour (3600 secons).
#'
#' @export
bcdc_cache_timeout <- function() {
  getOption("bcdata.cache_timeout", 3600)
}

#' Retrieve Default Cache Path
#'
#' Retrieves the default path used to cache the result of web requests. Makes
#' use of the \code{rappdirs} package to use cache folders
#' defined by each operating system
#'
#' @export
bcdc_cache_path <- function() {
  getOption("bcdata.cache_path", rappdirs::user_cache_dir("bcdata"))
}

#' Force collection of Web Service request from B.C. Data
#' Catalogue
#'
#' After tuning a query, `collect()` is used to actually
#' bring the data into memory. This will retrieve an sf
#' object into R. The `as_tibble()` function can be used
#' interchangeably with `collect` which matches `dbplyr`
#' behaviour.
#'
#' The result of `collect()`-ing a query will be cached to
#' avoid repeatedly requesting the same data from the
#' server. The duration of the caching can be customized
#' by setting the option `bcdc_cache_timeout` to a
#' different value (in seconds). The default is one hour
#' (3600 seconds).
#'
#' The cache can be cleared by running [bcdc_forget()].
#' Note this will clear the cache for all `collect()`
#' calls in the previous time frame specified in the
#' `bcdc_cache_timeout` option.
#'
#' @param x object of class bcdc_promise
#' @import memoise
#' @inheritParams collect
#' @rdname collect-methods
#' @export
#'
#' @examples
#' \donttest{
#' try(
#'   bcdc_query_geodata("bc-airports") %>%
#'     collect()
#' )
#'
#' try(
#'   bcdc_query_geodata("bc-airports") %>%
#'     as_tibble()
#' )
#' }
#'
collect.bcdc_promise <- memoise(
  collect_bcdc_promise_,
  ~ timeout(bcdc_cache_timeout()), # 1 hour
  cache = cache_filesystem(bcdc_cache_path())
)

#' Forget (clear) the cache of objects returned by
#' [collect()]
#'
#' @return `TRUE` if the cache existed previously and was
#'   successfully cleared, otherwise `FALSE`.
#' @export
bcdc_forget <- function() {
  memoise::forget(collect.bcdc_promise)
}

#' @inheritParams collect.bcdc_promise
#' @rdname collect-methods
#' @export
as_tibble.bcdc_promise <- collect.bcdc_promise

#' Show SQL and URL used for Web Service request from B.C. Data Catalogue
#'
#' Display Web Service query SQL
#'
#' @param x object of class bcdc_promise or bcdc_sf
#' @inheritParams show_query
#' @describeIn show_query show_query.bcdc_promise
#'
#' @export
#' @examples
#' \donttest{
#' try(
#'   bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
#'     filter(PERMIT_RELATIONSHIP == "DISCHARGE") %>%
#'     show_query()
#' )
#'   }
#'
show_query.bcdc_promise <- function(x, ...) {

  y <- list()
  y$base_url <- x$cli$url
  y$query_list <- x$query_list
  y$query_list$CQL_FILTER <- finalize_cql(y$query_list$CQL_FILTER)
  y$full_url <- x$cli$url_fetch(query = y$query_list)

  as.bcdc_query(y)

}



#' @describeIn show_query show_query.bcdc_promise
#'
#' @export
#' @examples
#' \donttest{
#' try(
#'   air <- bcdc_query_geodata("bc-airports") %>%
#'     collect()
#' )
#'
#' try(
#'   show_query(air)
#' )
#' }
show_query.bcdc_sf <- function(x, ...) {

  y <- list()
  y$url <- attr(x, "url")
  y$query_list <- attr(x, "query_list")
  y$full_url <- attr(x, "full_url")

  as.bcdc_query(y)
}

# collapse vector of cql statements into one
finalize_cql <- function(x, con = wfs_con) {
  if (is.null(x) || !length(x)) return(NULL)
  dbplyr::sql_vector(x, collapse = " AND ", con = con)
}

cat_line_wrap <- function(..., indent = 0, exdent = 1, col = NULL, background_col = NULL, file = stdout()) {
  txt <- strwrap(paste0(..., collapse = ""), indent = indent, exdent = exdent)
  cat_line(txt, col = col, background_col = background_col, file = file)
}
