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

compact <- function(l) Filter(Negate(is.null), l)


bcdc_number_wfs_records <- function(query_list, client){
  query_list <- c(query_list, resultType = "hits")

  res_max <- client$get(query = query_list)
  txt_max <- res_max$parse("UTF-8")


  ## resultType is only returned as XML.
  ## regex to extract the number
  as.numeric(sub(".*numberMatched=\"([0-9]{1,20})\".*", "\\1", txt_max))

}

check_geom_col_names <- function(query_list, cli){
  original_query <- query_list

  ## Change REQUEST so that it returns only col names
  query_list$REQUEST = "DescribeFeatureType"

  r = cli$get(query = query_list)
  txt = r$parse("UTF-8")

  # Converty from JSON and extract the data.frame of the feature properties
  cols <- jsonlite::fromJSON(txt, simplifyVector = TRUE)
  cols_df <- cols$featureTypes$properties[[1]]
  # Find the gml geometry field and get the name of the field
  geom_col <- cols_df[grepl("^gml:(multi)?(point|linestring|polygon|geometry)$",
                            tolower(cols_df$type)), "name"]

  if (geom_col != "GEOMETRY" && !is.null(original_query$CQL_FILTER)) {
    original_query$CQL_FILTER = gsub("GEOMETRY", geom_col, original_query$CQL_FILTER)
  }

  return(original_query)

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

bcdc_http_client <- function(url = NULL) {

  crul::HttpClient$new(url = url,
                       headers = list(`User-Agent` = "https://github.com/bcgov/bcdata"))

}

## Check if there is internet
## h/t to https://github.com/ropensci/handlr/blob/pluralize/tests/testthat/helper-handlr.R
has_internet <- function() {
  z <- try(suppressWarnings(readLines('https://www.google.com', n = 1)),
           silent = TRUE)
  !inherits(z, "try-error")
}
