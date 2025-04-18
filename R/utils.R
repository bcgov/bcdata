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

catalogue_base_url <- function() {
  getOption(
    "bcdata.catalogue_gui_url",
    default = "https://catalogue.data.gov.bc.ca/"
  )
}

catalogue_base_api_url <- function() {
  getOption(
    "bcdata.catalogue_api_url",
    default = "https://catalogue.data.gov.bc.ca/api/3"
  )
}

wfs_base_url <- function(host = bcdc_web_service_host()) {
  make_url(host, "geo/pub/wfs")
}

wms_base_url <- function(host = bcdc_web_service_host()) {
  make_url(host, "geo/pub/wms")
}

bcdc_web_service_host <- function() {
  getOption("bcdata.web_service_host", default = "https://openmaps.gov.bc.ca")
}

bcdata_user_agent <- function() {
  "https://github.com/bcgov/bcdata"
}

compact <- function(l) Filter(Negate(is.null), l)

#' Combine url components without having to worry
#' about slashes
#'
#' @param ... url components
#' @param trailing_slash should the url end in /
#'
#' @return complete url
#' @noRd
make_url <- function(..., trailing_slash = FALSE) {
  components <- unlist(list(...))
  components <- gsub("^/|/$", "", components)
  url <- paste(components, collapse = "/")
  if (trailing_slash) {
    url <- paste0(url, "/")
  }
  url
}

bcdc_number_wfs_records <- function(query_list, client) {
  if (!is.null(query_list$count)) {
    return(query_list$count)
  }

  if (!is.null(query_list$propertyName)) {
    query_list$propertyName <- NULL
  }

  query_list <- c(resultType = "hits", query_list)
  res_max <- client$post(body = query_list, encode = "form")
  catch_wfs_error(res_max)
  txt_max <- res_max$parse("UTF-8")

  ## resultType is only returned as XML.
  ## regex to extract the number
  as.numeric(sub(".*numberMatched=\"([0-9]{1,20})\".*", "\\1", txt_max))
}

specify_geom_name <- function(cols_df, CQL_statement) {
  # Find the geometry field and get the name of the field
  geom_col <- geom_col_name(cols_df)

  # substitute the geometry column name into the CQL statement and add sql class
  dbplyr::sql(glue::glue(CQL_statement, geom_name = geom_col))
}

bcdc_read_sf <- function(x, ...) {
  if (length(x) == 1) {
    return(sf::read_sf(x, stringsAsFactors = FALSE, quiet = TRUE, ...))
  } else {
    # tests that cover this are skipped due to large size
    # nocov start
    ## Parse the Paginated response
    message("Parsing data")
    sf_responses <- lapply(x, function(x) {
      sf::read_sf(x, stringsAsFactors = FALSE, quiet = TRUE, ...)
    })

    do.call(rbind, sf_responses)
    # nocov end
  }
}

slug_from_url <- function(x) {
  if (grepl("^(http|www)", x)) x <- basename(x)
  x
}

formats_supported <- function() {
  c(bcdc_read_functions()[["format"]], "zip")
}

bcdc_catalogue_client <- function(endpoint = NULL) {
  url <- make_url(catalogue_base_api_url(), endpoint)
  bcdc_http_client(url, auth = TRUE)
}

bcdc_wfs_client <- function(endpoint = NULL) {
  url <- make_url(wfs_base_url(), endpoint)
  bcdc_http_client(url, auth = FALSE)
}

bcdc_http_client <- function(url, auth = FALSE, ...) {
  headers <- list(
    `User-Agent` = bcdata_user_agent(),
    Authorization = if (auth) bcdc_auth() else NULL
  )

  crul::HttpClient$new(
    url = url,
    headers = compact(headers),
    opts = list(...)
  )
}

bcdc_auth <- function() {
  key <- Sys.getenv("BCDC_KEY")
  if (!nzchar(key)) return(NULL)
  message("Authorizing with your stored API key")
  key
}

## Check if there is internet
## h/t to https://github.com/ropensci/handlr/blob/pluralize/tests/testthat/helper-handlr.R
has_internet <- function() {
  z <- try(
    suppressWarnings(readLines('https://www.google.com', n = 1)),
    silent = TRUE
  )
  !inherits(z, "try-error")
}

# Need the actual name of the geometry column
geom_col_name <- function(x) {
  geom_type <- intersect(x$remote_col_type, gml_types())
  x[x$remote_col_type == geom_type, , drop = FALSE]$col_name
}

remove_id_col <- function(x) {
  setdiff(x, "id")
}

#' @param x a resource_df from formatted record
#' @noRd
wfs_available <- function(x) {
  x$location %in%
    c("bcgwdatastore", "bcgeographicwarehouse") &
    x$format == "wms"
}

#' @param x a resource_df from formatted record
#' @noRd
other_format_available <- function(x) {
  x$ext %in%
    formats_supported() &
    !x$location %in% c("bcgwdatastore", "bcgeographicwarehouse")
}

wfs_to_r_col_type <- function(col) {
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
formats_from_record <- function(x, trim = TRUE) {
  resource_df <- dplyr::tibble(
    name = purrr::map_chr(x$resources, "name"),
    url = purrr::map_chr(x$resources, safe_file_ext),
    format = purrr::map_chr(x$resources, "format")
  )
  x <- formats_from_resource(resource_df)

  if (trim) return(x[x != ""])

  x
}

formats_from_resource <- function(x) {
  dplyr::case_when(
    x$format == x$url ~ x$format,
    x$format == "wms" ~ "wms",
    !nzchar(x$url) ~ x$format,
    !nzchar(safe_file_ext(x)) ~ x$format,
    x$url == "zip" ~ paste0(x$format, "(zipped)"),
    TRUE ~ safe_file_ext(x)
  )
}

safe_file_ext <- function(resource) {
  url_format <- tools::file_ext(resource$url)
  url_format <- ifelse(url_format == "zip", resource$format, url_format)
  url_format
}

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
  warned <- ._bcdataenv_$named_get_record_warned
  if (!silence && !warned) {
    warning(..., call. = FALSE)
    assign("named_get_record_warned", TRUE, envir = ._bcdataenv_)
  }
}


clean_wfs <- function(x) {
  dplyr::case_when(
    x == "WMS getCapabilities request" ~ "WFS request (Spatial Data)",
    x == "wms" ~ "wfs",
    TRUE ~ x
  )
}

read_from_url <- function(resource, ...) {
  if (nrow(resource) > 1)
    stop("more than one resource specified", call. = FALSE)
  file_url <- resource$url
  reported_format <- safe_file_ext(resource)
  if (!reported_format %in% formats_supported()) {
    stop(
      "Reading ",
      reported_format,
      " files is not currently supported in bcdata."
    )
  }
  auth <- grepl("(cat(alogue)?|pub)\\.data\\.gov\\.bc\\.ca", file_url)
  cli <- bcdc_http_client(file_url, auth = auth)

  ## Establish where to download file
  tmp <- tempfile(
    tmpdir = unique_temp_dir(),
    fileext = paste0(".", tools::file_ext(file_url))
  )
  on.exit(unlink(tmp))

  r <- cli$get(disk = tmp)
  r$raise_for_status()

  tmp <- handle_zip(tmp)
  final_format <- tools::file_ext(tmp)

  # Match the read function to the file format format and retrieve the function
  funs <- bcdc_read_functions()
  fun <- funs[funs$format == final_format, ]

  # This assumes that the function we are using to read the data takes the
  # data as the first argument - will need revisiting if we find a situation
  # where that's not the case
  message(
    "Reading the data using the ",
    fun$fun,
    " function from the ",
    fun$package,
    " package."
  )
  handle_excel(tmp, ...)

  tryCatch(
    do.call(fun$fun, list(tmp, ...)),
    error = function(e) {
      stop(
        "Reading the data set failed with the following error message:\n\n  ",
        e,
        "\nThe file can be found here:\n  '",
        tmp,
        "'\nif you would like to try to read it manually.\n",
        call. = FALSE
      )
    }
  )
}


resource_to_tibble <- function(x) {
  res_df <- dplyr::tibble(
    name = safe_map_chr(x, "name"),
    url = safe_map_chr(x, "url"),
    id = safe_map_chr(x, "id"),
    format = safe_map_chr(x, "format"),
    ext = purrr::map_chr(x, safe_file_ext),
    package_id = safe_map_chr(x, "package_id"),
    location = simplify_string(safe_map_chr(x, "resource_storage_location"))
  )

  dplyr::mutate(
    res_df,
    wfs_available = wfs_available(res_df),
    bcdata_available = wfs_available | other_format_available(res_df)
  )
}

#' @importFrom rlang "%||%"
safe_map_chr <- function(x, name) {
  purrr::map_chr(x, ~ .x[[name]] %||% NA_character_)
}

simplify_string <- function(x) {
  tolower(gsub("\\s+", "", x))
}

pagination_sort_col <- function(cols_df) {
  cols <- cols_df[["col_name"]]
  # use OBJECTID or OBJECT_ID as default sort key, if present
  # if not present (several GSR tables), use SEQUENCE_ID
  # Then try FEATURE_ID
  for (idcol in c("OBJECTID", "OBJECT_ID", "SEQUENCE_ID", "FEATURE_ID")) {
    if (idcol %in% cols) return(idcol)
  }
  #Otherwise use the first column - this is likely pretty fragile
  warning(
    "Unable to find a suitable column to sort on for pagination. Using",
    " the first column (",
    cols[1],
    "). Please check your data for obvious duplicated or missing rows.",
    call. = FALSE
  )
  cols[1]
}

handle_zip <- function(x) {
  # Just give file back if it's not zipped
  if (!is_filetype(x, "zip")) {
    return(x)
  }
  # decompress into same dir
  dir <- dirname(x)
  utils::unzip(x, exdir = dir)
  unlink(x)
  files <- list_supported_files(dir)
  # check if it's a shapefile

  if (length(files) > 1L) {
    stop(
      "More than one supported file in zip file. It has been downloaded and ",
      "extracted to '",
      dir,
      "', where you can access its contents manually.",
      call. = FALSE
    )
  }

  files
}

handle_excel <- function(tmp, ...) {
  if (!is_filetype(tmp, c("xls", "xlsx"))) {
    return(invisible(NULL))
  }

  sheets <- readxl::excel_sheets(tmp)
  if (length(sheets) > 1L) {
    message(paste0(
      "\nThis .",
      tools::file_ext(tmp),
      " resource contains the following sheets: \n",
      paste0(" '", sheets, "'", collapse = "\n")
    ))
    if (!methods::hasArg("sheet")) {
      message(
        "Defaulting to the '",
        sheets[1],
        "' sheet. See ?bcdc_get_data for examples on how to specify a sheet.\n"
      )
    }
  }
}


unique_temp_dir <- function(pattern = "bcdata_") {
  dir <- tempfile(pattern = pattern)
  dir.create(file.path(dirname(dir), basename(dir)))
  dir
}

list_supported_files <- function(dir) {
  files <- list.files(dir, full.names = TRUE)
  supported <- is_filetype(files, formats_supported())

  if (!any(supported)) {
    # check if any are directories, if not bail, otherwise extract them
    if (!length(list.dirs(dir, recursive = FALSE))) {
      stop("No supported files found", call. = FALSE)
    }
    files <- list.files(dir, full.names = TRUE, recursive = TRUE)
    supported <- is_filetype(files, formats_supported())
  }

  files[supported]
}

catch_wfs_error <- function(catalogue_response) {
  msg <- "There was an issue sending this WFS request\n"

  if (inherits(catalogue_response, "Paginator")) {
    statuses <- catalogue_response$status_code()
    status_failed <- any(statuses >= 300)
    if (!status_failed) return(invisible(NULL))

    msg <- paste0(msg, paste0(length(statuses), " paginated requests issued"))
  } else {
    status_failed <- catalogue_response$status_code >= 300
    if (!status_failed) return(invisible(NULL))

    request_res <- catalogue_response$request_headers
    response_res <- catalogue_response$response_headers

    msg <- paste0(
      msg,
      cli::rule(line = "bar4", line_col = 'red'),
      "\n",
      "Request:",
      "\n  URL: ",
      catalogue_response$request$url$url,
      "\n  POST fields:\n    ",
      rawToChar(catalogue_response$request$options$postfields),
      "\n"
    )

    for (i in seq_along(request_res)) {
      msg <- paste0(
        msg,
        "  ",
        names(request_res)[i],
        ": ",
        request_res[i],
        "\n"
      )
    }
    msg <- paste0(msg, "Response:\n")
    for (i in seq_along(response_res)) {
      msg <- paste0(
        msg,
        "  ",
        names(response_res)[i],
        ": ",
        response_res[i],
        "\n"
      )
    }
  }

  stop(msg, call. = FALSE)
}

names_to_lazy_tbl <- function(x) {
  stopifnot(is.character(x))
  frame <- as.data.frame(stats::setNames(rep(list(logical()), length(x)), x))
  dbplyr::tbl_lazy(frame)
}

is_empty <- function(x) {
  length(x) == 0
}
