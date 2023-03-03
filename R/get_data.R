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
#' @param record either a `bcdc_record` object (from the result of `bcdc_get_record()`),
#' a character string denoting the name or ID of a resource (or the URL) or a BC Geographic
#' Warehouse (BCGW) name.
#'
#' It is advised to use the permanent ID for a record or the BCGW name rather than the
#' human-readable name to guard against future name changes of the record.
#' If you use the human-readable name a warning will be issued once per
#' session. You can silence these warnings altogether by setting an option:
#' `options("silence_named_get_data_warning" = TRUE)` - which you can set
#' in your .Rprofile file so the option persists across sessions.
#'
#' @param resource optional argument used when there are multiple data files
#' within the same record. See examples.
#' @param ... arguments passed to other functions. Tabular data is passed to a function to handle
#' the import based on the file extension. [bcdc_read_functions()] provides details on which functions
#' handle the data import. You can then use this information to look at the help pages of those functions.
#' See the examples for a workflow that illustrates this process.
#' For spatial Web Feature Service data the `...` arguments are passed to [bcdc_query_geodata()].
#' @param verbose When more than one resource is available for a record,
#' should extra information about those resources be printed to the console?
#' Default `TRUE`
#'
#'
#' @return An object of a type relevant to the resource (usually a tibble or an sf object, a list if the resource is a json file)
#' @export
#'
#' @examples
#' \donttest{
#' # Using the record and resource ID:
#' try(
#'   bcdc_get_data(record = '76b1b7a3-2112-4444-857a-afccf7b20da8',
#'                 resource = '4d0377d9-e8a1-429b-824f-0ce8f363512c')
#' )
#'
#' try(
#'   bcdc_get_data('1d21922b-ec4f-42e5-8f6b-bf320a286157')
#' )
#'
#' # Using a `bcdc_record` object obtained from `bcdc_get_record`:
#' try(
#'   record <- bcdc_get_record('1d21922b-ec4f-42e5-8f6b-bf320a286157')
#' )
#'
#' try(
#'   bcdc_get_data(record)
#' )
#'
#' # Using a BCGW name
#' try(
#'   bcdc_get_data("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
#' )
#'
#' # Using sf's sql querying ability
#' try(
#'   bcdc_get_data(
#'     record = '30aeb5c1-4285-46c8-b60b-15b1a6f4258b',
#'     resource = '3d72cf36-ab53-4a2a-9988-a883d7488384',
#'     layer = 'BC_Boundary_Terrestrial_Line',
#'     query = "SELECT SHAPE_Length, geom FROM BC_Boundary_Terrestrial_Line WHERE SHAPE_Length < 100"
#'   )
#' )
#'
#' ## Example of correcting import problems
#'
#' ## Some initial problems reading in the data
#' try(
#'   bcdc_get_data('d7e6c8c7-052f-4f06-b178-74c02c243ea4')
#' )
#'
#' ## From bcdc_get_record we realize that the data is in xlsx format
#' try(
#'  bcdc_get_record('8620ce82-4943-43c4-9932-40730a0255d6')
#' )
#'
#' ## bcdc_read_functions let's us know that bcdata
#' ## uses readxl::read_excel to import xlsx files
#' try(
#'  bcdc_read_functions()
#' )
#'
#' ## bcdata let's you know that this resource has
#' ## multiple worksheets
#' try(
#'  bcdc_get_data('8620ce82-4943-43c4-9932-40730a0255d6')
#' )
#'
#' ## we can control what is read in from an excel file
#' ## using arguments from readxl::read_excel
#' try(
#'   bcdc_get_data('8620ce82-4943-43c4-9932-40730a0255d6', sheet = 'Regional Districts')
#' )
#' }
#'
#' ## Pass an argument through to a read_* function
#'
#' try(
#'   bcdc_get_data(record = "a2a2130b-e853-49e8-9b30-1d0c735aa3d9",
#'                 resource = "0b9e7d31-91ff-4146-a473-106a3b301964")
#' )
#'
#' ## we can control some properties of the list object returned by
#' ## jsonlite::read_json by setting simplifyVector = TRUE or
#' ## simplifyDataframe = TRUE
#' try(
#'  bcdc_get_data(record = "a2a2130b-e853-49e8-9b30-1d0c735aa3d9",
#'                 resource = "0b9e7d31-91ff-4146-a473-106a3b301964",
#'                 simplifyVector = TRUE)
#' )
#' @export
bcdc_get_data <- function(record, resource = NULL, verbose = TRUE, ...) {
  if (!has_internet()) stop("No access to internet", call. = FALSE) # nocov
  UseMethod("bcdc_get_data")
}

#' @export
bcdc_get_data.default <- function(record, resource = NULL, verbose = TRUE, ...) {
  stop("No bcdc_get_data method for an object of class ", class(record),
       call. = FALSE)
}

#' @export
bcdc_get_data.character <- function(record, resource = NULL, verbose = TRUE, ...) {

  if (is_whse_object_name(record)) {
    query <- bcdc_query_geodata(record, ...)
    return(collect(query))
  }

  if (grepl("/resource/", record)) {
    #  A full url was passed including record and resource compenents.
    # Grab the resource id and strip it off the url
    resource <- slug_from_url(record)
    record <- gsub("/resource/.+", "", record)
  }

  x <- slug_from_url(record)
  x <- bcdc_get_record(x)

  bcdc_get_data(x, resource, verbose = verbose, ...)
}

#' @export
bcdc_get_data.bcdc_record <- function(record, resource = NULL, verbose = TRUE, ...) {
  record_id <- record$id

  # Only work with resources that are available to read into R
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
    if (!resource %in% resource_df$id) {
      stop("The specified resource does not exist in this record", call. = FALSE)
    }
    return(read_from_url(resource_df[resource_df$id == resource, , drop = FALSE],
                         ...))
  }

  ## non-wms; only one resource and not specified
  if (nrow(resource_df) == 1L) {
    return(read_from_url(resource_df, ...))
  }

  ## wms record with at least one non BCGW resource (test bc-airports)
  ## tabular; multiple resources (test grizzly)

  # Can't test due to interactive menu
  # nocov start

  if (interactive() && verbose) {
    cat_line_wrap("The record you are trying to access appears to have more than one resource.")
    cat_line()
    cat_line("Resources:")

    for (r in seq_len(nrow(resource_df))) {
      record_print_helper(resource_df[r, ], r)
    }

    cat_line("--------")
  }

  choices <- clean_wfs(resource_df$name)

  ## To deal with situations where the resource names are the same
  if(any(duplicated(choices))) choices <- glue::glue("{choices} ({resource_df$format})")

  choice_input <- utils::menu(choices, title = "Please choose one option:")

  if (choice_input == 0) stop("No resource selected", call. = FALSE)

  name_choice <- choices[choice_input]

  if (name_choice == "WFS request (Spatial Data)") {
    ## todo
    # cat_line_wrap("To directly access this record in the future please use this command:")
    # cat_line_wrap(glue::glue("bcdc_get_data('{x}', resource = '{id_choice}')"))
    query <- bcdc_query_geodata(record = record_id, ...)
    return(collect(query))
  } else {
    resource <- resource_df[choice_input, , drop = FALSE]
    id_choice <- resource_df$id[choice_input]

    message("To directly access this resource in the future please use this command:\n",
            glue::glue("bcdc_get_data('{record_id}', resource = '{id_choice}')"),"\n")
    read_from_url(resource, ...)
  }
  # nocov end
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
#' @importFrom jsonlite read_json
#' @export
#'


bcdc_read_functions <- function(){
  dplyr::tribble(
    ~format,   ~package,    ~fun,
    "kml",     "sf",        "read_sf",
    "geojson", "sf",        "read_sf",
    "gpkg",    "sf",        "read_sf",
    "gdb",     "sf",        "read_sf",
    "fgdb",    "sf",        "read_sf",
    "shp",     "sf",        "read_sf",
    "csv",     "readr",     "read_csv",
    "txt",     "readr",     "read_tsv",
    "tsv",     "readr",     "read_tsv",
    "xlsx",    "readxl",    "read_xlsx",
    "xls",     "readxl",    "read_xls",
    "json",    "jsonlite",  "read_json"
  )
}
