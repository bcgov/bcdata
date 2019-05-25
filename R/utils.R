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

base_url <- function() "https://catalogue.data.gov.bc.ca/api/3/"

bcdata_user_agent <- function(){
  "https://github.com/bcgov/bcdata"
}

compact <- function(l) Filter(Negate(is.null), l)


bcdc_number_wfs_records <- function(query_list, client){

  query_list <- c(query_list, resultType = "hits")

  if(!is.null(query_list$propertyName)){
    query_list$propertyName <- NULL
  }

  res_max <- client$get(query = query_list)
  txt_max <- res_max$parse("UTF-8")

  ## resultType is only returned as XML.
  ## regex to extract the number
  as.numeric(sub(".*numberMatched=\"([0-9]{1,20})\".*", "\\1", txt_max))

}

specify_geom_name <- function(record, CQL_statement){

  cols_df <- record$details

  # Catch when no details df:
  if (!any(dim(cols_df))) {
    warning("Unable to determine the name of the geometry column; assuming 'GEOMETRY'",
            call. = FALSE)
    return(CQL_statement)
  }

  # Find the geometry field and get the name of the field
  geom_col <- cols_df$column_name[cols_df$data_type == "SDO_GEOMETRY"]


  glue::glue_sql(glue::glue(CQL_statement, geom_name = geom_col))
  # if (geom_col != "GEOMETRY" && !is.null(query_list$CQL_FILTER)) {
  #   query_list$CQL_FILTER = gsub("GEOMETRY", geom_col, query_list$CQL_FILTER)
  # }


}

bcdc_read_sf <- function(x, ...){

  if(length(x) == 1){

    return(sf::read_sf(x, stringsAsFactors = FALSE, quiet = TRUE, ...))

  } else{
    ## Parse the Paginated response
    message("Parsing data")
    sf_responses <- lapply(x, function(x) {sf::read_sf(x, stringsAsFactors = FALSE, quiet = TRUE, ...)})

    do.call(rbind, sf_responses)
  }



}

slug_from_url <- function(x) {
  if (grepl("^(http|www)", x)) x <- basename(x)
  x
}

formats_supported <- function(){
  bcdc_read_functions()[["format"]]
}

bcdc_http_client <- function(url = NULL) {

  crul::HttpClient$new(url = url,
                       headers = list(`User-Agent` = bcdata_user_agent()))

}

## Check if there is internet
## h/t to https://github.com/ropensci/handlr/blob/pluralize/tests/testthat/helper-handlr.R
has_internet <- function() {
  z <- try(suppressWarnings(readLines('https://www.google.com', n = 1)),
           silent = TRUE)
  !inherits(z, "try-error")
}


# Need the actual name of the geometry column
geom_col_name <- function(x){
  cols_df <- x$details

  # Find the geometry field and get the name of the field
  cols_df[cols_df$data_type == "SDO_GEOMETRY",]$column_name
}

## Currently used to identify is record is wfs/wms enabled
resource_locations <- function(x){
  x <- purrr::map_chr(seq_along(x$resources), ~x[["resources"]][[.x]][["resource_storage_location"]])
  ## to rectify inconsistent "BCGW DataStore" and "BCGW Data Store"
  tolower(gsub("\\s", "", x))
}

wfs_to_r_col_type <- function(col){

  dplyr::case_when(
    col == "xsd:string" ~ "character",
    col == "xsd:date" ~ "date",
    col == "xsd:decimal" ~ "numeric",
    col == "xsd:hexBinary" ~ "numeric",
    grepl("^gml:", col) ~ "sfc geometry",
    TRUE ~ as.character(col)
  )
}


##from a record
formats_from_record <- function(x, trim = TRUE){

  resource_df <- dplyr::tibble(
      name = purrr::map_chr(x$resources, "name"),
      url = safe_file_ext(purrr::map_chr(x$resources, "url")),
      format = purrr::map_chr(x$resources, "format")
    )
  x <- formats_from_resource(resource_df)

  if(trim) return(x[x != ""])

  x
}

formats_from_resource <- function(x){
  dplyr::case_when(
    x$format == x$url ~ x$format,
    x$format == "wms" ~ "wms",
    nchar(x$url) == 0 ~ x$format,
    nchar(safe_file_ext(x$url)) == 0 ~ x$format,
    x$url == "zip" ~ paste0(x$format, "(zipped)"),
    TRUE ~ safe_file_ext(x$url)
  )
}

safe_file_ext <- function(x) as.character(tools::file_ext(x))

gml_types <- function(x) {
  c(
    "gml:PointPropertyType",
    "gml:CurvePropertyType",
    "gml:SurfacePropertyType",
    "gml:GeometryPropertyType",
    "gml:MultiPointPropertyType",
    "gml:MultiCurvePropertyType",
    "gml:MultiSurfacePropertyType",
    "gml:MultiGeometryPropertyType"
  )
}

get_record_warn_once <- function(...) {
  silence <- isTRUE(getOption("silence_named_get_record_warning"))
  warned <- bcdata_env$named_get_record_warned
  if (!silence && !warned) {
    warning(..., call. = FALSE)
    assign("named_get_record_warned", TRUE, envir = bcdata_env)
  }
}



is_emptyish <- function(x){
  length(x) == 0 || !nzchar(x)
}



clean_wfs <- function(x){
  dplyr::case_when(
    x == "WMS getCapabilities request" ~ "WFS request (Spatial Data)",
    x == "wms" ~ "wfs",
    TRUE ~ x
  )
}

safe_request_length <- function(query_list){
  ## A conservative number of characters in the filter call.
  ## Calculating from the query_list BEFORE the call actually happen.

  ## Tested wfs url character limit
  limits <- 5000
  request_length <- nchar(finalize_cql(query_list$CQL_FILTER))

  return(request_length <= limits)

}

read_from_url <- function(file_url, ...){
  format <- safe_file_ext(file_url)
  if (!format %in% formats_supported()) {
    stop("Reading ", format, " files is not currently supported in bcdata.")
  }

  cli <- bcdc_http_client(file_url)

  ## Establish where to download file
  tmp <- tempfile(fileext = paste0(".", format))
  on.exit(unlink(tmp))

  r <- cli$get(disk = tmp)
  r$raise_for_status()

  # Match the read function to the file format format and retrieve the function
  funs <- bcdc_read_functions()
  fun <- funs[funs$format == format, ]

  # This assumes that the function we are using to read the data takes the
  # data as the first argument - will need revisiting if we find a situation
  # where that's not the case
  message("Reading the data using the ", fun$fun, " function from the ",
          fun$package, " package.")
  do.call(fun$fun, list(tmp, ...))
}

resource_to_tibble <- function(x){
  dplyr::tibble(
    name = purrr::map_chr(x, "name"),
    url = purrr::map_chr(x, "url"),
    id = purrr::map_chr(x, "id"),
    format = purrr::map_chr(x, "format"),
    ext = safe_file_ext(url),
    package_id = purrr::map_chr(x, "package_id"),
    location = simplify_string(purrr::map_chr(x, "resource_storage_location"))
  )
}

simplify_string <- function(x) {
  tolower(gsub("\\s+", "", x))
}

url_format <- function(url) {
  url <- gsub("&", "&\n", url)
  sub("SERVICE", "\nSERVICE", url)
}

pagination_sort_col <- function(x) {
  cols <- bcdc_describe_feature(x)[["col_name"]]
  # use OBJECTID or OBJECT_ID as default sort key, if present
  # if not present (several GSR tables), use SEQUENCE_ID
  # Then try FEATURE_ID
  for (idcol in c("OBJECTID", "OBJECT_ID", "SEQUENCE_ID", "FEATURE_ID")) {
    if (idcol %in% cols) return(idcol)
  }
  #Otherwise use the first column - this is likely pretty fragile
  warning("Unable to find a suitable column to sort on for pagination. Using",
          " the first column (", cols[1],
          "). Please check your data for obvious duplicated or missing rows.",
          call. = FALSE)
  cols[1]
}
