# Copyright 2021 Province of British Columbia
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

#' Generate a bibentry from a Data Catalogue Record
#'
#' Generate a bibentry object for use .bib file.
#' for more details
#'
#' @inheritParams bcdc_get_record
#' @export
#'
#' @seealso \link{utils::bibentry}
#'
#' @examples
#'
#' try(
#' bcdc_get_citation("76b1b7a3-2112-4444-857a-afccf7b20da8")
#' )
bcdc_get_citation <- function(id) {
  rec <- bcdc_get_record(id)

  bib_rec <- utils::bibentry(
    bibtype = "Manual",
    title = rec$title,
    author = person(rec$organization$title),
    organization = clean_org_name(rec),
    year = format(as.Date(rec$record_last_modified), "%Y"),
    url = paste0(catalogue_base_url(), "dataset/", rec$id),
    note = rec$license_title
  )



  structure(bib_rec,
            class = c("citation", setdiff(class(bib_rec), "citation"))
  )

}

clean_org_name <- function(rec) {
  name <- jsonlite::fromJSON(rec$contacts)$name
  name <- trimws(name)
  name <- paste0(name, collapse = ", ")
  sub(",([^,]*)$", " &\\1", name)
}
