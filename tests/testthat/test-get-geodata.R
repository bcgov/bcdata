context("testing ability of bcdc_get_geodata to retrieve for bcdc")

test_that("bcdc_get_geodata returns an sf object for a valid id", {
  bc_airports <- bcdc_get_geodata("bc-airports")
  expect_is(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})
