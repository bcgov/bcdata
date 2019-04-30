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

#' Download and read a dataset from a B.C. Data Catalogue resource
#'
#'
#' @param x either a `bcdc_record` object (from the result of `bcdc_get_record()`)
#' or a character string denoting the id of a resource (or the url).
#' @param format Defaults to NULL which will first check to see if the record is a WMS/WFS record.
#' If so an sf object is returned. Otherwise a format needs to be specified. `bcdc_get_record` can
#' be used to identify which formats are available.
#' @param resource option argument used when there are multiple data files of the same format
#' within the same record. See examples.
#' @param ... arguments passed to other functions. For spatial (WMS/WFS) data these are passed to
#' `bcdc_query_geodata()`. Non spatial data is passed to a function to handle the import based
#' on the file extension.
#'
#' @return an object of a type relevant to the resource (usually a tibble or an sf object)
#' @export
#'
#' @examples
#' \dontrun{
#' bcdc_get_data("bc-airports")
#' bcdc_get_data("bc-winery-locations", format = "csv")
#' bcdc_get_data("local-government-population-and-household-projections-2018-2027",
#' format = "xlsx", sheet = "Population", skip = 1)
#'
#' }
bcdc_get_data <- function(x, format = NULL, resource = NULL,...) {
  UseMethod("bcdc_get_data")
}

#' @export
bcdc_get_data.bcdc_record <- function(x, format = NULL, resource = NULL, ...) {
  if(!has_internet()) stop("No access to internet", call. = FALSE)

  stop("not working yet!")
  # record can be either a url/slug or a bcdata_record
  if (!interactive())
    stop("Calling bcdc_get_data on a bcdc_record object is only meant for interactive use")
  x <- utils::menu("pick one")
  bcdc_get_data(x)
}

#' @export
bcdc_get_data.character <- function(x, format = NULL, resource = NULL, ...) {
  x <- slug_from_url(x)

  if(is.null(format)){
    query <- bcdc_query_geodata(x = x, ...)
    return(collect(query))
  }

  if(!all(format %in% formats_supported())){
    stop(paste0("The ", format, " extension is not currently supported by bcdata"),
         call. = FALSE)
  }

  record <- bcdc_get_record(x)

  resource_df <- dplyr::tibble(
      name = purrr::map_chr(record$resources, "name"),
      url = purrr::map_chr(record$resources, "url"),
      id = purrr::map_chr(record$resources, "id"),
      format = purrr::map_chr(record$resources, "format"),
      ext = tools::file_ext(url)
    )

  ## Specifying id
  if(length(resource_df$ext[resource_df$ext %in% format]) > 1 && !is.null(resource)){
    file_url <- resource_df$url[resource_df$id == resource]
  }

  ## Using menu to figure out resource
  if(length(resource_df$ext[resource_df$ext %in% format]) > 1 && is.null(resource) && interactive()){

    cat(glue::glue(
      "The record you are trying to access appears to have more than one resource with a '{format}' extension."
    ))
    cat("\n Resources: \n")

    purrr::walk(record$resources[which(resource_df$ext == format)], record_print_helper)

    cat("--------\n")
    cat("Please choose one option:")
    choices <- resource_df$name[resource_df$ext %in% format]
    choice_input <- utils::menu(choices)

    if(choice_input == 0) stop("No resource selected", call. = FALSE)

    name_choice <- choices[choice_input]
    file_url <- resource_df$url[resource_df$name == name_choice]
    id_choice <- resource_df$id[resource_df$name == name_choice]

    cat("To directly access this record in the future please use this command:\n")
    cat(glue::glue("bcdc_get_data('{x}', format = '{format}', resource = '{id_choice}')"),"\n")

  }

  ## Bonk if not using interactively
  if(length(resource_df$ext[resource_df$ext %in% format]) > 1  && is.null(resource) && !interactive()){
    stop("The record you are trying to access appears to have more than one resource
         with a glue::glue{format} extension.", call. = TRUE)

  }

  ## Go through if there aren't multiple resources
  if(length(resource_df$ext[resource_df$ext %in% format]) == 1 && is.null(resource)){
    file_url <- resource_df$url[resource_df$ext == format]
  }




  ## Do we need this?
  cli <- bcdc_http_client(file_url)
  r <- cli$get()
  r$raise_for_status()

  ## Download file then read it in.
  tmp <- tempfile(fileext = paste0(".", format))
  on.exit(unlink(tmp))
  utils::download.file(file_url, tmp, mode = 'wb', quiet = FALSE)

  read_fun <- function(x, type) {
    switch(type,
           "csv" = readr::read_csv(x, ...),
           "kml" = bcdc_read_sf(x, ...),
           "txt" = readr::read_tsv(x, ...),
           "xlsx" = readxl::read_excel(x, ...),
           "xls" = readxl::read_excel(x, ...))
  }

  read_fun(x = tmp, type = format)

}

