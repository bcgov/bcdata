context("testing ability of bcdc_get_geodata to retrieve for bcdc")

test_that("bcdc_get_geodata returns an sf object for a valid id", {
  skip_if_net_down()
  bc_airports <- bcdc_get_geodata("bc-airports")
  expect_is(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})

test_that("bcdc_get_geodata accepts R expressions to refine data call",{
  skip_if_net_down()
  one_well <- bcdc_get_geodata("ground-water-wells",
                               OBSERVATION_WELL_NUMBER == 108)
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("bcdc_get_geodata succeeds with a records over 10000 rows",{
  skip("Skipping the BEC test, though available for testing")
  expect_silent(bcdc_get_geodata("terrestrial-protected-areas-representation-by-biogeoclimatic-unit"))
})


test_that("bcdc_get_geodata works with slug and full url", {
  skip_if_net_down()
  expect_is(ret1 <- bcdc_get_geodata("https://catalogue.data.gov.bc.ca/dataset/bc-airports"),
            "sf")
  expect_is(ret2 <- bcdc_get_geodata("bc-airports"),
            "sf")
  expect_is(ret3 <- bcdc_get_geodata("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8"),
            "sf")
  expect_is(ret4 <- bcdc_get_geodata("76b1b7a3-2112-4444-857a-afccf7b20da8"),
            "sf")
  ## Must be a better way to test if these objects are equal
  expect_true(all(unlist(lapply(list(ret1, ret2, ret3, ret4), nrow))))
  expect_true(all(unlist(lapply(list(ret1, ret2, ret3, ret4), ncol))))
})


test_that("bcdc_get_geodata works with spatial data that have SHAPE for the geom",{
  ## View metadata to see that geom is SHAPE
  ##bcdc_browse("fire-perimeters-historical")

  crd <- bcdc_get_geodata("regional-districts-legally-defined-administrative-areas-of-bc",
                          ADMIN_AREA_NAME == "Cariboo Regional District")

  ret1 <- bcdc_get_geodata("fire-perimeters-historical",
                                FIRE_YEAR == 2000,
                                FIRE_CAUSE == "Person",
                                INTERSECTS(crd))
  expect_is(ret1, "sf")
})
