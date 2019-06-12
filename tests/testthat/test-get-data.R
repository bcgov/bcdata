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


test_that("bcdc_get_data can return the wms resource when it is specified by resource",{
  expect_is(bcdc_get_data("bc-airports", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"), "sf")
})


test_that("a wms record with only one resource works with only the record id",{
  expect_is(bcdc_get_data("bc-college-region-boundaries"), "sf")
  })




