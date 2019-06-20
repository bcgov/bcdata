context("testing ability of bcdc_get_data to retrieve an valid object")

test_that("bcdc_get_data collects an sf object for a valid record and resource id", {
  skip_if_net_down()
  bc_airports <- bcdc_get_data("bc-airports", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c")
  expect_is(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})


test_that("bcdc_get_data works with slug and full url with corresponding resource", {
  skip_if_net_down()
  expect_is(ret1 <- bcdc_get_data("https://catalogue.data.gov.bc.ca/dataset/bc-airports", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")
  expect_is(ret2 <- bcdc_get_data("bc-airports", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")
  expect_is(ret3 <- bcdc_get_data("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")
  expect_is(ret4 <- bcdc_get_data("76b1b7a3-2112-4444-857a-afccf7b20da8", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")
  ## Must be a better way to test if these objects are equal
  expect_true(all(unlist(lapply(list(ret1, ret2, ret3, ret4), nrow))))
  expect_true(all(unlist(lapply(list(ret1, ret2, ret3, ret4), ncol))))
})


test_that("bcdc_get_data works with a non-wms record with only one resource",{
  name <- "criminal-code-traffic-offences"
  expect_is(bcdc_get_data(name), "tbl")
})

test_that("bcdc_get_data works when using read_excel arguments",{
  name <- "local-government-population-and-household-projections-2018-2027"
  expect_is(bcdc_get_data(name, sheet = "Population", skip = 1), "tbl")
})

test_that("bcdc_get_data works with an xls when specifying a specific resource",{
  name <- 'bc-grizzly-bear-habitat-classification-and-rating'
  expect_is(bcdc_get_data(name, resource = '7b09f82f-e7d0-44bf-9310-b94039b323a8'), "tbl")
})

test_that("bcdc_get_data will return non-wms resources",{
  expect_is(bcdc_get_data(record = '76b1b7a3-2112-4444-857a-afccf7b20da8',
                 resource = 'fcccba36-b528-4731-8978-940b3cc04f69'), "tbl")

  expect_is(bcdc_get_data(record = 'fa542137-a976-49a6-856d-f1201adb2243',
                          resource = 'dc1098a7-a4b8-49a3-adee-9badd4429279'), "tbl")
})

test_that("bcdc_get_data works with a zipped shp file", {
  expect_is(bcdc_get_data(record = '68f2f577-28a7-46b4-bca9-7e9770f2f357',
                          resource = 'f89f99b0-ca68-41e2-afc4-63fdc0edb666'),
            "sf")
})

test_that("unknown single file (shp) inside zip", {
  expect_is(bcdc_get_data("e31f7488-27fa-4330-ae86-160a0deb8a59"),
            "sf")
})

test_that("fails when multiple files in a zip", {
  expect_error(bcdc_get_data("300c0980-b5e3-4202-b0da-d816f14fadad"),
               "More than one file in zip file")
})

test_that("bcdc_get_data can return the wms resource when it is specified by resource",{
  expect_is(bcdc_get_data("bc-airports", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"), "sf")
})


test_that("a wms record with only one resource works with only the record id",{
  expect_is(bcdc_get_data("bc-college-region-boundaries"), "sf")
  })

test_that("bcdc_get_data works with a bcdc_record object", {
  record <- bcdc_get_record("bc-college-region-boundaries")
  expect_is(bcdc_get_data(record), "sf")

  record <- bcdc_get_record('fa542137-a976-49a6-856d-f1201adb2243')
  expect_is(bcdc_get_data(record,
                          resource = 'dc1098a7-a4b8-49a3-adee-9badd4429279'),
            "tbl")
})

test_that("bcdc_get_data fails with invalid input", {
  expect_error(bcdc_get_data(35L),
               "No bcdc_get_data method for an object of class integer")
})


