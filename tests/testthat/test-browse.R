context("confirm browsing ability")

test_that("bcdc_get_geodata returns an sf object for a valid id", {
  skip_if_net_down()
  forest_url <- bcdc_browse("forest")
  expect_identical(forest_url, "https://catalogue.data.gov.bc.ca/dataset?q=forest")
  catalogue_url <- bcdc_browse()
  expect_identical(catalogue_url, "https://catalogue.data.gov.bc.ca")

})
