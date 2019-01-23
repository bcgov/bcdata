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
    browser()

    query_list <- c(query_list, resultType="hits")

    res_max <- client$get(query = query_list)
    txt_max <- res_max$parse("UTF-8")

    ## resultType is only returned as XML. Will parse instead on importing an
    ## XML package
    ## regex to extract the number
    first_pass <- gsub(".*numberMatched", "", txt_max)
    as.numeric(sub("^\\D*(\\d+).*$", "\\1", first_pass))

}

slug_from_url <- function(x) {
  if (grepl("^(http|www)", x)) x <- basename(x)
  x
}

bcdc_http_client <- function(url = NULL) {

  crul::HttpClient$new(url = url,
                       headers = list(`User-Agent` = "https://github.com/bcgov/bcdata"))

}
