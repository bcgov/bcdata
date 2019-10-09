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
  new_query <- specify_geom_name(ap, query_list[["CQL_FILTER"]])
  expect_equal(as.character(new_query), "DWITHIN(SHAPE, foobar)")
  expect_is(new_query, "sql")
})

test_that("get_record_warn_once warns once and only once", {
  options("silence_named_get_record_warning" = FALSE)
  expect_warning(get_record_warn_once("Hi"))
  expect_silent(get_record_warn_once("Hi"))
  options("silence_named_get_record_warning" = TRUE)
})

test_that("pagination_sort_col works", {
  expect_equal(pagination_sort_col("76b1b7a3-2112-4444-857a-afccf7b20da8"),
               "SEQUENCE_ID")
  expect_equal(pagination_sort_col("2ebb35d8-c82f-4a17-9c96-612ac3532d55"),
               "OBJECT_ID")
  expect_equal(pagination_sort_col("634ee4e0-c8f7-4971-b4de-12901b0b4be6"),
               "OBJECTID")
})

test_that("is_whse_object_name works", {
  expect_true(is_whse_object_name("BCGW_FOO.BAR_BAZ"))
  expect_false(is_whse_object_name("bcgw_foo.bar_baz"))
  expect_false(is_whse_object_name("foo"))
  expect_false(is_whse_object_name(structure(list(), class = "bcdc_record")))
})
