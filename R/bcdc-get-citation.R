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
#' Generate a "TechReport" bibentry object directly from a catalogue record.
#' The primary use of this function is as a helper to create a `.bib` file for use
#' in reference management software to cite data from the B.C. Data Catalogue.
#' This function is likely to be starting place for this process and manual
#' adjustment will often be needed. The bibentries are not designed to be
#' authoritative and may not reflect all fields required for individual
#' citation requirements.
#'
#'
#' @param record either a `bcdc_record` object (from the result of `bcdc_get_record()`),
#' a character string denoting the name or ID of a resource (or the URL)
#'
#' It is advised to use the permanent ID for a record rather than the
#' human-readable name to guard against future name changes of the record.
#' If you use the human-readable name a warning will be issued once per
#' session. You can silence these warnings altogether by setting an option:
#' `options("silence_named_get_data_warning" = TRUE)` - which you can set
#' in your .Rprofile file so the option persists across sessions.
#'
#' @examples
#'
#' @seealso [utils::bibentry()]
#'
#' try(
#' bcdc_get_citation("76b1b7a3-2112-4444-857a-afccf7b20da8")
#' )
#'
#' ## Or directly on a record object
#' try(
#' rec <- bcdc_get_record("76b1b7a3-2112-4444-857a-afccf7b20da8")
#' bcdc_get_citation(rec)
#' )
#' @export
bcdc_get_citation <- function(record) {
  if (!has_internet()) stop("No access to internet", call. = FALSE) # nocov
  UseMethod("bcdc_get_citation")
}

#' @export
bcdc_get_citation.default <- function(record) {
  stop("No bcdc_get_citation method for an object of class ", class(record),
       call. = FALSE)
}

#' @export
bcdc_get_citation.character <- function(record) {

  if (grepl("/resource/", record)) {
    #  A full url was passed including record and resource compenents.
    # Grab the resource id and strip it off the url
    resource <- slug_from_url(record)
    record <- gsub("/resource/.+", "", record)
  }


  rec <- bcdc_get_record(record)

  bcdc_get_citation(rec)

}

#' @export
bcdc_get_citation.bcdc_record <- function(record) {

  bib_rec <- utils::bibentry(
    bibtype = "techreport",
    title = record$title,
    author = utils::person(record$organization$title),
    address = clean_org_name(record),
    institution = "Province of British Columbia",
    year = format(as.Date(record$record_last_modified), "%Y"),
    howpublished = paste0("Record accessed ", Sys.Date()),
    url = paste0(catalogue_base_url(), "dataset/", record$id),
    note = record$license_title
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
