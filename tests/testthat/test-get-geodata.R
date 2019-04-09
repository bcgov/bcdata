context("testing ability of bcdc_get_geodata to retrieve an sf object")

test_that("bcdc_get_geodata collects an sf object for a valid id", {
  skip_if_net_down()
  bc_airports <- bcdc_get_geodata("bc-airports")
  expect_is(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})


test_that("bcdc_get_geodata works with slug and full url using collect", {
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





