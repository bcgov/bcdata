test_that("recods with wms but inconsistent layer_name, object_name fields work", {
  skip_if_net_down()
  skip_on_cran()
  # https://github.com/bcgov/bcdata/issues/138
  # layer_name = RSLT_PLANTING_ALL_RSLT_CF
  # object_name = WHSE_FOREST_VEGETATION.RSLT_PLANTING_SVW
  # wms uses object_name
  expect_s3_class(bcdc_query_geodata("results-planting"), "bcdc_promise")

  # https://github.com/bcgov/bcdata/issues/129
  # layer_name = WHSE_ADMIN_BOUNDARIES.ADM_NR_DISTRICTS_SPG
  # wms uses layer_name (generalized)
  expect_message(
    expect_s3_class(
      bcdc_query_geodata("natural-resource-nr-district"),
      "bcdc_promise"
    ),
    "You are accessing a simplified view of the data"
  )
})
