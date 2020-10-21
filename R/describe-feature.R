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

#' Describe the attributes of a Web Service feature
#'
#' Describe the attributes of column of a record accessed through the Web Service.
#' This can be a useful tool to examine a layer before issuing a query with `bcdc_query_geodata`.
#'
#' @return
#' `bcdc_describe_features` returns a tibble describing the attributes of a B.C. Data Catalogue record.
#' The tibble returns the following columns:
#'   - col_name: attributes of the feature
#'   - sticky: whether a column can be separated from the record in a Web Service call via the `dplyr::select` method
#'   - remote_col_type: class of what is return by the web feature service
#'   - local_col_type: the column class in R
#'
#' @inheritParams bcdc_query_geodata
#' @export
#'
#' @examples
#' \donttest{
#' try(
#'   bcdc_describe_feature("bc-airports")
#' )
#'
#' try(
#'   bcdc_describe_feature("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
#' )
#' }
#'
#' @export
bcdc_describe_feature <- function(record){
  if (!has_internet()) stop("No access to internet", call. = FALSE) # nocov
  UseMethod("bcdc_describe_feature")
}

#' @export
bcdc_describe_feature.default <- function(record) {
  stop("No bcdc_describe_feature method for an object of class ", class(record),
       call. = FALSE)
}

#' @export
bcdc_describe_feature.character <- function(record){

  if (is_whse_object_name(record)) {
    return(feature_helper(record))
  }

  bcdc_describe_feature(bcdc_get_record(record))
}


#' @export
bcdc_describe_feature.bcdc_record <- function(record){

  if (!any(wfs_available(record$resource_df))) {
    stop("No WMS/WFS resource available for this data set.",
         call. = FALSE
    )
  }

  feature_helper(record$layer_name)
}

parse_raw_feature_tbl <- function(query_list){

  ## GET and parse data to sf object
  cli <- bcdc_wfs_client()

  cc <- cli$post(body = query_list, encode = "form")

  catch_wfs_error(cc)

  xml_res <- xml2::read_xml(cc$parse("UTF-8"))
  xml_res <- xml2::xml_find_all(xml_res, "//xsd:sequence")
  xml_res <- xml2::xml_find_all(xml_res, ".//xsd:element")
  xml_res <- purrr::map(xml_res, xml2::xml_attrs)
  xml_df <- purrr::map_df(xml_res, ~ as.list(.))


  attr(xml_df, "geom_type") <- intersect(xml_df$type, gml_types())

  return(xml_df)
}

feature_helper <- function(whse_name){

  query_list <- list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "DescribeFeatureType",
    typeNames = whse_name)

  ## This is an ugly way of doing this
  ## Manually add id and turn into a row
  id_row <- dplyr::tibble(name = "id",
                          nillable = FALSE,
                          type = "xsd:string")

  xml_df <- parse_raw_feature_tbl(query_list)
  geom_type <- attr(xml_df, "geom_type")

  ## Identify geometry column and move to last
  # xml_df[xml_df$type == geom_type, "name"] <- "geometry"
  # xml_df <- dplyr::bind_rows(xml_df[xml_df$name != "geometry",],
  #                            xml_df[xml_df$name == "geometry",])

  ## Fix logicals
  xml_df$nillable = ifelse(xml_df$nillable == "true", TRUE, FALSE)

  xml_df <- xml_df[, c("name", "nillable", "type")]
  ## Add the id_row back into the front
  xml_df <- dplyr::bind_rows(id_row, xml_df)
  colnames(xml_df) <- c("col_name", "sticky", "remote_col_type")
  xml_df$local_col_type <- wfs_to_r_col_type(xml_df$remote_col_type)

  xml_df
}




