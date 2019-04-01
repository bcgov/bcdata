context("test-utils")

test_that("check_geom_col_names works", {
  skip_if_net_down()
  query_list <- list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = "bc-airports",
    CQL_FILTER = "DWITHIN(GEOMETRY, foobar)")

  ap <- bcdc_get_record("bc-airports")
  new_query <- check_geom_col_names(ap, query_list)
  expect_equal(new_query$CQL_FILTER, "DWITHIN(SHAPE, foobar)")
})
