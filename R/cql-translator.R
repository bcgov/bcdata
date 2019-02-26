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
  sql_where <- dbplyr::translate_sql_(dots, con = cql_dummy_con)
  build_where(sql_where)
}

# Builds a complete WHERE clause from multiple WHERE statements
# Modified from dbplyr:::sql_clause_where
build_where <- function(where) {
  if (length(where) > 0L) {
    where_paren <- dbplyr::escape(where, parens = TRUE)
    dbplyr::build_sql(dbplyr::sql_vector(where_paren, collapse = " AND "))
  }
}

# Define custom translations from R functions to filter functions supported
# by cql: https://docs.geoserver.org/stable/en/user/filter/function_reference.html
cql_scalar <- dbplyr::sql_translator(
  .parent = dbplyr::base_scalar,
  tolower = dbplyr::sql_prefix("strToLowerCase", 1),
  toupper = dbplyr::sql_prefix("strToUpperCase", 1),
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
sql_translate_env.DummyCQL <- function(con) {
  dbplyr::sql_variant(
    cql_scalar,
    cql_agg,
    dbplyr::base_no_win
  )
}

# Make sure that identities (LHS of relations) are escaped with double quotes
sql_escape_ident.DummyCQL <- function(con, x) {
  dbplyr::sql_quote(x, "\"")
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
  spatial_predicates <- grepl(spatial_funs_regex(first = TRUE), dots)
  dots[spatial_predicates] <- lapply(dots[spatial_predicates],
                                     rlang::eval_tidy)
  dots
}

