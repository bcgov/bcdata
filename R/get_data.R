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

#' Download and read a resource from a B.C. Data Catalogue record
#'
#' @param record either a `bcdc_record` object (from the result of `bcdc_get_record()`)
#' or a character string denoting the name or ID of a resource (or the URL).
#'
#' It is advised to use the permament ID for a record rather than the
#' human-readable name to guard against future name changes of the record.
#' If you use the human-readable name a warning will be issued once per
#' session. You can silence these warnings altogether by setting an option:
#' `options("silence_named_get_data_warning" = TRUE)` - which you can set
#' in your .Rprofile file so the option persists across sessions.
#'
#' @param resource optional argument used when there are multiple data files
#' within the same record. See examples.
#' @param ... arguments passed to other functions. Tabular data is passed to a function to handle
#' the import based on the file extension. `bcdc_read_functions()` provides details on which functions
#' handle the data import. You can then use this information to look at the help pages of those functions.
#' See the examples for a workflow that illustrates this process.
#' For spatial Web Service data the `...` arguments are passed to `bcdc_query_geodata()`.
#'
#' @return An object of a type relevant to the resource (usually a tibble or an sf object)
#' @export
#'
#' @examples
#' \dontrun{
#' # Using the record and resource ID:
#' bcdc_get_data(record = '76b1b7a3-2112-4444-857a-afccf7b20da8',
#'               resource = '4d0377d9-e8a1-429b-824f-0ce8f363512c')
#' bcdc_get_data('1d21922b-ec4f-42e5-8f6b-bf320a286157')
#'
#' # Using a `bcdc_record` object obtained from `bcdc_get_record`:
#' record <- bcdc_get_record('1d21922b-ec4f-42e5-8f6b-bf320a286157')
#' bcdc_get_data(record)
#'
#' ## Example of correcting import problems
#'
#' ## Some initial problems reading in the data
#' bcdc_get_data('d7e6c8c7-052f-4f06-b178-74c02c243ea4')
#'
#' ## From bcdc_get_record we realize that the data is in xlsx format
#' bcdc_get_record('d7e6c8c7-052f-4f06-b178-74c02c243ea4')
#'
#' ## bcdc_read_functions let's us know that bcdata
#' ## uses readxl::read_excel to import xlsx files
#' bcdc_read_functions()
#'
#' ## If you read the help page for readxl::read_excel,
#' ## it seems likely that we need to skip the first row:
#' bcdc_get_data('d7e6c8c7-052f-4f06-b178-74c02c243ea4', skip = 1)
#'
#' }
#'
#' @export
bcdc_get_data <- function(record, resource = NULL, ...) {
  if (!has_internet()) stop("No access to internet", call. = FALSE)
  UseMethod("bcdc_get_data")
}

#' @export
bcdc_get_data.default <- function(record, resource = NULL, ...) {
  stop("No bcdc_get_data method for an object of class ", class(record),
       call. = FALSE)
}

#' @export
bcdc_get_data.character <- function(record, resource = NULL, ...) {
  x <- slug_from_url(record)
  record <- bcdc_get_record(x)
  bcdc_get_data(record, resource, ...)
}

#' @export
bcdc_get_data.bcdc_record <- function(record, resource = NULL, ...) {
  record_id <- record$id

  # Only work with resources that are avaialable to read into R
  resource_df <- record$resource_df[record$resource_df$bcdata_available, ]


  if (!nrow(resource_df)) {
    stop("There are no resources that bcdata can download from this record", call. = FALSE)
  }

  ## fail if not using interactively and haven't specified resource
  if (is.null(resource) && nrow(resource_df) > 1L && !interactive()) {
    stop("The record you are trying to access appears to have more than one resource.", call. = TRUE)
  }

  # get wms info
  wms_resource_id <- resource_df$id[resource_df$format == "wms"]
  wms_enabled <- !is_emptyish(wms_resource_id)

  ## wms record; resource supplied OR wms is the only resource
  if (wms_enabled) {
    if (nrow(resource_df) == 1L || identical(wms_resource_id, resource)) {
      query <- bcdc_query_geodata(record = record_id, ...)
      return(collect(query))
    }
  }

  ## non-wms; resource specified
  if (!is.null(resource)) {
    return(read_from_url(resource_df[resource_df$id == resource, , drop = FALSE],
                         ...))
  }

  ## non-wms; only one resource and not specified
  if (nrow(resource_df) == 1L) {
    return(read_from_url(resource_df, ...))
  }

  ## wms record with at least one non BCGW resource (test bc-airports)
  ## tabular; multiple resources (test grizzly)
  cat("The record you are trying to access appears to have more than one resource.")
  cat("\n Resources: \n")

  for (r in seq_len(nrow(resource_df))) {
    record_print_helper(resource_df[r, ], r)
  }

  cat("--------\n")
  cat("Please choose one option:")
  choices <- clean_wfs(resource_df$name)
  choice_input <- utils::menu(choices)

  if (choice_input == 0) stop("No resource selected", call. = FALSE)

  name_choice <- choices[choice_input]

  if (name_choice == "WFS request (Spatial Data)") {
    ## todo
    # cat("To directly access this record in the future please use this command:\n")
    # cat(glue::glue("bcdc_get_data('{x}', resource = '{id_choice}')"),"\n")
    query <- bcdc_query_geodata(record = record_id, ...)
    return(collect(query))
  } else {
    resource <- resource_df[resource_df$name == name_choice, , drop = FALSE]
    id_choice <- resource_df$id[resource_df$name == name_choice]

    cat("To directly access this record in the future please use this command:\n")
    cat(glue::glue("bcdc_get_data('{record_id}', resource = '{id_choice}')"),"\n")
    read_from_url(resource, ...)
  }
}

#' Formats supported and loading functions
#'
#' Provides a tibble of formats supported by bcdata and the associated function that
#' reads that data into R. This function is meant as a resource to determine which parameters
#' can be passed through the `bcdc_get_data` function to the reading function. This is
#' particularly important to know if the data requires using arguments from the read in function.
#' @importFrom readr read_csv
#' @importFrom readr read_tsv
#' @importFrom sf read_sf
#' @importFrom readxl read_xlsx
#' @importFrom readxl read_xls
#' @export
#'


bcdc_read_functions <- function(){
  dplyr::tribble(
    ~format, ~package, ~fun,
    "kml", "sf", "read_sf",
    "geojson", "sf", "read_sf",
    "gpkg", "sf", "read_sf",
    "shp", "sf", "read_sf",
    "csv", "readr", "read_csv",
    "txt", "readr", "read_tsv",
    "xlsx", "readxl", "read_xlsx",
    "xls", "readxl", "read_xls"
  )
}
