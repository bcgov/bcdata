context("test-utils")

test_that("check_geom_col_names works", {
  skip_if_net_down()
  query_list <- list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = "bc-airports",
    CQL_FILTER = "DWITHIN({geom_col}, foobar)")

  ap <- bcdc_get_record("bc-airports")
  new_query <- specify_geom_name(ap, query_list)
  expect_equal(new_query, "DWITHIN(SHAPE, foobar)")
})

test_that("get_record_warn_once warns once and only once", {
  options("silence_named_get_record_warning" = FALSE)
  expect_warning(get_record_warn_once("Hi"))
  expect_silent(get_record_warn_once("Hi"))
  options("silence_named_get_record_warning" = TRUE)
})
