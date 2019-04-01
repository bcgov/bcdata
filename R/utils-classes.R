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

## Add "bcdc_promise" class
as.bcdc_promise <- function(x, sql_string) {
  structure(x,
            sql_string = sql_string,
            class = c("bcdc_promise", setdiff(class(x), "bcdc_promise"))
  )
}

#' @export
print.bcdc_promise <- function(x) {

  query_list <- c(x$query_list, COUNT = 10)
  cli <- bcdc_http_client(url = "https://openmaps.gov.bc.ca/geo/pub/wfs")

  ## Change CQL query on the fly if geom is SHAPE
  query_list <- check_geom_col_names(query_list, cli)

  cc <- cli$get(query = query_list)
  cc$raise_for_status()

  txt <- cc$parse("UTF-8")

  print(bcdc_read_sf(txt))
}
