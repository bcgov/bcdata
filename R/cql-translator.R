# Function to translate R code to CQL
cql_translate <- function(...) {
  sql_where <- dbplyr::translate_sql(..., con = cql_dummy_con)
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
  DWITHIN = function(x) DWITHIN(x)
  # More here
)

# No aggregation functions available
no_agg <- function(f) {
  force(f)

  function(...) {
    stop("Aggregation function `", f, "()` is not supported by this database",
         call. = FALSE)
  }
}

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


## Geometry Predicates

DWITHIN <- function(geom) {
  dbplyr::sql(bcdc_cql_string(geom, "DWITHIN"))
}

