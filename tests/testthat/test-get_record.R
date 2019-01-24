context("test-get_record")

test_that("bcdc_get_record works with slug and full url", {
  skip_if_net_down()
  expect_is(ret1 <- bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/bc-airports"),
           "bcdc_record")
  expect_is(ret2 <- bcdc_get_record("bc-airports"),
           "bcdc_record")
  expect_is(ret3 <- bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8"),
           "bcdc_record")
  expect_is(ret4 <- bcdc_get_record("76b1b7a3-2112-4444-857a-afccf7b20da8"),
           "bcdc_record")
  expect_equal(ret1$title, "BC Airports")
  lapply(list(ret2, ret3, ret4), expect_equal, ret1)
})

test_that("bcdc_search_facets works", {
  skip_if_net_down()
  ret_names <- c("facet", "count", "display_name", "name")
  lapply(c("license_id", "download_audience", "type", "res_format",
           "sector", "organization"),
         function(x) expect_named(bcdc_search_facets(x))
  )
  expect_error(bcdc_search_facets("foo"), "'arg' should be one of")
})

test_that("bcdc_list works", {
  skip_if_net_down()
  ret <- bcdc_list()
  expect_is(ret, "character")
  expect_gt(length(ret), 1000)
})

test_that("bcdc_search works", {
  skip_if_net_down()
  expect_is(bcdc_search("forest"), "bcdc_recordlist")
  expect_is(bcdc_search("regional district",
                        type = "Geographic", res_format = "fgdb"),
            "bcdc_recordlist")
})
