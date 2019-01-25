context("testing ability of bcdc_get_geodata to retrieve for bcdc")

test_that("bcdc_get_geodata returns an sf object for a valid id", {
  skip_if_net_down()
  bc_airports <- bcdc_get_geodata("bc-airports")
  expect_is(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})

test_that("bcdc_get_geodata accept CQL strings to refine data call",{
  skip_if_net_down()
  one_well <- bcdc_get_geodata("ground-water-wells",
                               query = "OBSERVATION_WELL_NUMBER=108")
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("bcdc_get_geodata succeeds with a records over 10000 rows",{
  skip("Skipping the BEC test, though available for testing")
  expect_silent(bcdc_get_geodata("terrestrial-protected-areas-representation-by-biogeoclimatic-unit"))
})
