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
#' or a character string denoting the id of a resource (or the url).
#'
#' It is advised to use the permament id for a record rather than the
#' human-readable name to guard against future name changes of the record.
#' If you use the human-readable name a warning will be issued once per
#' session. You can silence these warnings altogether by setting an option:
#' `options("silence_named_get_data_warning" = TRUE)` - which you can set
#' in your .Rprofile file so the option persists across sessions.
#'
#' @param resource option argument used when there are multiple data files of the same format
#' within the same record. See examples.
#' @param ... arguments passed to other functions. Tabular data is passed to a function to handle
#' the import based on the file extension. `bcdc_read_functions()` provides details on which functions
#' handle the data import. You can then use this information to look at the help pages of those functions.
#' See the examples for a workflow that illustrates this process.
#' For spatial (WMS/WFS) data the `...` arguments are passed to `bcdc_query_geodata()`.
#'
#' @return an object of a type relevant to the resource (usually a tibble or an sf object)
#' @export
#'
#' @examples
#' \dontrun{
#' bcdc_get_data(record = '76b1b7a3-2112-4444-857a-afccf7b20da8',
#'               resource = '4d0377d9-e8a1-429b-824f-0ce8f363512c')
#' bcdc_get_data('1d21922b-ec4f-42e5-8f6b-bf320a286157')
#'
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
bcdc_get_data <- function(record, resource = NULL,...) {
  UseMethod("bcdc_get_data")
}

#' @export
bcdc_get_data.bcdc_record <- function(record, resource = NULL, ...) {
  if(!has_internet()) stop("No access to internet", call. = FALSE)

  stop("not working yet!")
  # record can be either a url/slug or a bcdata_record
  if (!interactive())
    stop("Calling bcdc_get_data on a bcdc_record object is only meant for interactive use")
  x <- utils::menu("pick one")
  bcdc_get_data(record)
}

#' @export
bcdc_get_data.character <- function(record, resource = NULL, ...) {
  x <- slug_from_url(record)

  record <- bcdc_get_record(x)

  resource_df <- resource_to_tibble(record$resources)

  wms_resource_id <- resource_df$id[resource_df$format == "wms"]


  ## wms record; resource supplied
  if(identical(wms_resource_id, resource)){
      query <- bcdc_query_geodata(record = x, ...)
      return(collect(query))
  }

  ## wms record; no aux resources
  if(!is_emptyish(wms_resource_id) && all(unique(resource_df$location) %in% c("bcgwdatastore","bcgeographicwarehouse"))){
    query <- bcdc_query_geodata(record = x, ...)
    return(collect(query))
  }

  ## wms record with at least one non BCGW resource (test bc-airports)
  wms_non_bcgw_res <- !is_emptyish(wms_resource_id) && any(unique(resource_df$location) != "bcgwdatastore")
  if(wms_non_bcgw_res  && is.null(resource) && interactive()){
    cat("The record you are trying to access appears to have more than one resource.")
    cat("\n Resources: \n")

    ind <- (resource_df$format == "wms" & resource_df$location == "bcgwdatastore") | resource_df$location != "bcgwdatastore"

    purrr::walk(record$resources[ind], record_print_helper)

    cat("--------\n")
    cat("Please choose one option:")
    choices <- clean_wfs(resource_df$name[ind])
    choice_input <- utils::menu(choices)

    if(choice_input == 0) stop("No resource selected", call. = FALSE)

    name_choice <- choices[choice_input]

    if(name_choice == "WFS request (Spatial Data)"){
      ## todo
      # cat("To directly access this record in the future please use this command:\n")
      # cat(glue::glue("bcdc_get_data('{x}', resource = '{id_choice}')"),"\n")
        query <- bcdc_query_geodata(record = x, ...)
        return(collect(query))
    } else{
      file_url <- resource_df$url[resource_df$name == name_choice]
      id_choice <- resource_df$id[resource_df$name == name_choice]

      cat("To directly access this record in the future please use this command:\n")
      cat(glue::glue("bcdc_get_data('{x}', resource = '{id_choice}')"),"\n")
    }

  }

  ## tabular; multiple resources (test grizzly)
  no_wms_supp_res <- is_emptyish(wms_resource_id) && nrow(resource_df[resource_df$format %in% formats_supported(),]) > 1
  if(no_wms_supp_res && is.null(resource) && interactive()){

    cat("The record you are trying to access appears to have more than one resource.")
    cat("\n Resources: \n")

    purrr::walk(record$resources[which(resource_df$ext %in% formats_supported())], record_print_helper)

    cat("--------\n")
    cat("Please choose one option:")
    choices <- resource_df$name[resource_df$ext %in% formats_supported()]
    choice_input <- utils::menu(choices)

    if(choice_input == 0) stop("No resource selected", call. = FALSE)

    name_choice <- choices[choice_input]
    file_url <- resource_df$url[resource_df$name == name_choice]
    id_choice <- resource_df$id[resource_df$name == name_choice]

    cat("To directly access this record in the future please use this command:\n")
    cat(glue::glue("bcdc_get_data('{x}', resource = '{id_choice}')"),"\n")

  }

  ## fail if not using interactively and haven't specified resource
  if(is.null(resource) && nrow(resource_df) > 1 && !interactive()){
    stop("The record you are trying to access appears to have more than one resource.", call. = TRUE)
  }

  ## tabular; only one resource and not specified
  if(nrow(resource_df) == 1 && is.null(resource)){
    file_url <- resource_df$url
  }


  ## tabular; resource specified
  if(!is.null(resource)){
    file_url <- resource_df$url[resource_df$id == resource]
  }


  read_from_url(file_url, ...)

}

#' Formats supported and loading functions
#'
#' Provides a tibble of formats supported by bcdata and the associated function that
#' reads that data into R. This function is meant as a resource to determine which parameters
#' can be passed through the `bcdc_get_data` function to the reading function. This is
#' particularly important to know if the data requires using arguments from the read in function.
#'
#' @export
#'

bcdc_read_functions <- function(){
  dplyr::tribble(
    ~format, ~package, ~fun,
    "csv", "readr", "read_csv",
    "kml", "sf", "read_sf",
    "txt", "readr", "read_tsv",
    "xlsx", "readxl", "read_xlsx",
    "xls", "readxl", "read_xls"
  )
}
