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

# Ensure these are loaded first so dblplyr::sql_translator
# can find them
#' @include cql-geom-predicates.R
NULL

#' @importFrom rlang :=

# Function to translate R code to CQL
cql_translate <- function(..., .colnames = character(0)) {
  ## convert dots to list of quosures
  dots <- rlang::quos(...)
  ## run partial_eval on them to evaluate named objects in the environment
  ## in which they were defined.
  ## e.g., if x is defined in the global env and passed as on object to
  ## filter, need to evaluate x in the global env.
  ## This also evaluates any functions defined in cql_scalar so that the spatial
  ## predicates and CQL() expressions are evaluated into valid CQL code
  ## so they can be combined with the rest of the query
  dots <- lapply(dots, function(x) {
    rlang::new_quosure(
      dbplyr::partial_eval(x, data = names_to_lazy_tbl(.colnames))
    )
  })

  sql_where <- dbplyr::translate_sql_(dots, con = wfs_con, window = FALSE)

  build_where(sql_where)
}

# Builds a complete WHERE clause from a vector of WHERE statements
# Modified from dbplyr:::sql_clause_where
build_where <- function(where, con = wfs_con) {
  if (length(where) > 0L) {
    where_paren <- dbplyr::escape(where, parens = TRUE, con = con)
    dbplyr::build_sql(
      dbplyr::sql_vector(where_paren, collapse = " AND ", con = con),
      con = con
    )
  }
}

bcdc_identity <- function(f) {
  function(x, ...) {
    do.call(f, c(x, list(...)))
  }
}

# Define custom translations from R functions to filter functions supported
# by cql: https://docs.geoserver.org/stable/en/user/filter/function_reference.html
cql_scalar <- dbplyr::sql_translator(
  .parent = dbplyr::base_scalar,
  tolower = dbplyr::sql_prefix("strToLowerCase", 1),
  toupper = dbplyr::sql_prefix("strToUpperCase", 1),
  between = function(x, left, right) {
    CQL(paste0(x, " BETWEEN ", left, " AND ", right))
  },
  CQL = CQL,
  # Override dbplyr::base_scalar functions which convert to SQL
  # operations intended for the backend database, but we want them to operate
  # locally
  `[` = `[`,
  `[[` = `[[`,
  `$` = `$`,
  as.Date = function(x, ...) as.character(as.Date(x, ...)),
  as.POSIXct = function(x, ...) as.character(as.POSIXct(x, ...)),
  as.numeric = bcdc_identity("as.numeric"),
  as.double = bcdc_identity("as.double"),
  as.integer = bcdc_identity("as.integer"),
  as.character = bcdc_identity("as.character"),
  as.logical = function(x, ...) as.character(as.logical(x, ...)),
  # Geometry predicates
  EQUALS = EQUALS,
  DISJOINT = DISJOINT,
  INTERSECTS = INTERSECTS,
  TOUCHES = TOUCHES,
  CROSSES = CROSSES,
  WITHIN = WITHIN,
  CONTAINS = CONTAINS,
  OVERLAPS = OVERLAPS,
  RELATE = RELATE,
  DWITHIN = DWITHIN,
  BEYOND = BEYOND,
  BBOX = BBOX
)

# No aggregation functions available in CQL
no_agg <- function(f) {
  force(f)

  function(...) {
    stop("Aggregation function `", f, "()` is not supported by this database",
         call. = FALSE)
  }
}

# Construct the errors for common aggregation functions
cql_agg <- dbplyr::sql_translator(
  n          = no_agg("n"),
  mean       = no_agg("mean"),
  var        = no_agg("var"),
  sum        = no_agg("sum"),
  min        = no_agg("min"),
  max        = no_agg("max")
)

#' @importFrom dbplyr dbplyr_edition
#' @export
dbplyr_edition.wfsConnection <- function(con) 2L

#' wfsConnection class
#'
#' @import methods
#' @import DBI
#' @export
#' @keywords internal
setClass("wfsConnection",
         contains = "DBIConnection"
)

# A dummy connection object to ensure the correct sql_translate is used
wfs_con <- structure(
  list(),
  class = c("wfsConnection", "DBIConnection")
)

# Custom sql_translator using cql variants defined above
#' @keywords internal
#' @importFrom dbplyr sql_translation
#' @export
sql_translation.wfsConnection <- function(conn) {
  dbplyr::sql_variant(
    cql_scalar,
    cql_agg,
    dbplyr::base_no_win
  )
}

#' @rdname CQL
#' @export
#' @aliases
#'   CQL-class
setClass("CQL", contains = c("SQL", "character"))

# Make sure that identities (LHS of relations) are escaped with double quotes

#' @keywords internal
#' @rdname wfsConnection-class
#' @exportMethod dbQuoteIdentifier
#' @export
setMethod("dbQuoteIdentifier", c("wfsConnection", "CQL"),
          function(conn, x) dbplyr::sql_quote(x, "\""))

# Make sure that strings (RHS of relations) are escaped with single quotes

#' @keywords internal
#' @rdname wfsConnection-class
#' @exportMethod dbQuoteString
#' @export
setMethod("dbQuoteString", c("wfsConnection", "CQL"),
          function(conn, x) dbplyr::sql_quote(x, "'"))
