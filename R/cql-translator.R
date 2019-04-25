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

# Function to translate R code to CQL
cql_translate <- function(...) {
  # when there are spatial predicates (e.g., DWITHIN, INTERSECTS, TOUCHES)
  # evaluate those parts of the expression so they are expanded
  dots <- expand_spatial_predicates(...)
  dots <- expand_cql(dots)
  sql_where <- dbplyr::translate_sql_(dots, con = cql_dummy_con, window = FALSE)
  build_where(sql_where)
}

# Builds a complete WHERE clause from multiple WHERE statements
# Modified from dbplyr:::sql_clause_where
build_where <- function(where, con = cql_dummy_con) {
  if (length(where) > 0L) {
    where_paren <- dbplyr::escape(where, parens = TRUE, con = con)
    dbplyr::build_sql(
      dbplyr::sql_vector(where_paren, collapse = " AND ", con = con),
      con = con
    )
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
  DWITHIN = function(x) DWITHIN(x),
  EQUALS = function(x) EQUALS(x),
  DISJOINT = function(x) DISJOINT(x),
  INTERSECTS = function(x) INTERSECTS(x),
  TOUCHES = function(x) TOUCHES(x),
  CROSSES = function(x) CROSSES(x),
  WITHIN = function(x) WITHIN(x),
  CONTAINS = function(x) CONTAINS(x),
  OVERLAPS = function(x) OVERLAPS(x),
  RELATE = function(x) RELATE(x),
  DWITHIN = function(x) DWITHIN(x),
  BEYOND = function(x) BEYOND(x)
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


# A dummy connection object to ensure the correct sql_translate is used
cql_dummy_con <- structure(
  list(),
  class = c("DummyCQL", "DBITestConnection", "DBIConnection")
)

# Custom sql_translator using cql variants defined above
#' @keywords internal
#' @importFrom dplyr sql_translate_env
#' @export
sql_translate_env.DummyCQL <- function(con) {
  dbplyr::sql_variant(
    cql_scalar,
    cql_agg,
    dbplyr::base_no_win
  )
}

# Make sure that identities (LHS of relations) are escaped with double quotes
#' @keywords internal
#' @importFrom dplyr sql_escape_ident
#' @export
sql_escape_ident.DummyCQL <- function(con, x) {
  dbplyr::sql_quote(x, "\"")
}

# Make sure that strings (RHS of relations) are escaped with single quotes
#' @keywords internal
#' @importFrom dplyr sql_escape_string
#' @export
sql_escape_string.DummyCQL <- function(con, x) {
  dbplyr::sql_quote(x, "'")
}

# Regex for looking for spatial functions, optionally only at the beginning
# of a string
spatial_funs_regex <- function(first = FALSE) {
  funs <- paste(cql_geom_predicate_list(), collapse = "|")
  if (first) {
    return(paste0("^(", funs, ")"))
  }
  funs
}

expand_spatial_predicates <- function(...) {
  # This works with expressions separated by commas
  # E.g., expand_spatial_predicates(foo == "bar", DWITHIN(bc_bound()))
  # But need to figure out a way to break it out if separated by & or |:
  # expand_spatial_predicates(foo == "bar" | DWITHIN(bc_bound()))
  dots <- rlang::exprs(...)
  # Find the expressions that are cql spatial funcions and evaluate them
  # so the geometry is expanded and inserted into the CQL function call.
  # eval_tidy needs the env to be 3 levels deep so that it can find the object
  # that is being used in the spatial predicate function:
  #  - expand_spatial_predicates is called by cql_translate
  #  - cql_translate is called by bcdc_get_geodata
  spatial_predicates <- grepl(spatial_funs_regex(first = TRUE), dots)
  dots[spatial_predicates] <- lapply(dots[spatial_predicates],
                                     rlang::eval_tidy,
                                     env = rlang::caller_env(n = 3))
  dots
}

expand_cql <- function(dots) {
  cql_calls <- grepl("^CQL\\((\"|')", dots)
  dots[cql_calls] <- lapply(dots[cql_calls], rlang::eval_tidy)
  dots
}

#' CQL escaping
#'
#' Write a CQL expression to escape its inputs, and return a CQL/SQL object.
#' Used when writing filter expressions in [bcdc_get_geodata()].
#'
#' See [the CQL/ECQL for Geoserver website](https://docs.geoserver.org/stable/en/user/tutorials/cql/cql_tutorial.html).
#'
#' @param ... Character vectors that will be comined into a single CQL statement.
#'
#' @return An object of class `c("CQL", "SQL")`
#' @export
#'
#' @examples
#' CQL("FOO > 12 & NAME LIKE 'A&'")
CQL <- function(...) {
    sql <- dbplyr::sql(...)
    structure(sql, class = c("CQL", class(sql)))
}

