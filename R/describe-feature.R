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

#' Describe a WFS feature
#'
#' Describe the columns from a WFS feature. The column name, whether a column can be
#' separated from the record in WFS (nillable) and the tpye of column are returned.
#' This can be a helpful tool to examine a layer before issuing a query with `bcdc_get_geodata`
#'
#' @inheritParams bcdc_get_geodata
#' @export
#'
#' @examples
#'  bcdc_describe_feature("bc-airports")

bcdc_describe_feature <- function(x = NULL){
  obj <- bcdc_get_record(x)
  if (!"wms" %in% vapply(obj$resources, `[[`, "format", FUN.VALUE = character(1))) {
    stop("No wms/wfs resource available for this dataset.",
         call. = FALSE
    )
  }

  ## Parameters for the API call
  query_list <- list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "DescribeFeatureType",
    #outputFormat = "application/json",
    typeNames = obj$layer_name
  )


  ## GET and parse data to sf object
  cli <- bcdc_http_client(url = "https://openmaps.gov.bc.ca/geo/pub/wfs")

  cc <- cli$get(query = query_list)
  status_failed <- cc$status_code >= 300

  xml_res <- xml2::read_xml(cc$parse("UTF-8"))
  xml_res <- xml2::xml_find_all(xml_res, "//xsd:sequence")
  xml_res <- xml2::xml_find_all(xml_res, ".//xsd:element")
  xml_res <-  purrr::map(xml_res, xml2::xml_attrs)
  xml_df <- purrr::map_df(xml_res, ~as.list(.))

  ## This is an ugly way of doing this
  ## Manually add id and turn into a row
  id_row <- dplyr::tibble(name = "id",
                          nillable = FALSE,
                          type = "xsd:string")

  ## Extracting geometry column and turn into a row
  geom_row <- xml_df[xml_df$type == "gml:GeometryPropertyType",]
  ## Because the object will always be imported into R as "geometry" we change the name here
  geom_row$name <- "geometry"

  ## Remove the geom row
  xml_df <- xml_df[!xml_df$type == "gml:GeometryPropertyType",]

  ## Add geom col to last position
  xml_df <- dplyr::bind_rows(xml_df, geom_row)

  ## Fix logicals
  xml_df$nillable = ifelse(xml_df$nillable == "true", TRUE, FALSE)

  xml_df <- xml_df[,c("name", "nillable","type")]
  ## Add the id_row back into the front
  xml_df <- dplyr::bind_rows(id_row, xml_df)
  colnames(xml_df) <- c("col_name", "selectable", "remote_col_type")
  xml_df$local_col_type <- wfs_to_r_col_type(xml_df$remote_col_type)

  xml_df
}
