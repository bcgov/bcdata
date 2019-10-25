# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

context("test-get_record")

test_that("bcdc_get_record works with slug and full url", {
  skip_on_cran()
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
  skip_on_cran()
  skip_if_net_down()
  ret_names <- c("facet", "count", "display_name", "name")
  lapply(c("license_id", "download_audience", "type", "res_format",
           "sector", "organization"),
         function(x) expect_named(bcdc_search_facets(x))
  )
  expect_error(bcdc_search_facets("foo"), "'arg' should be one of")
})

test_that("bcdc_list works", {
  skip_on_cran()
  skip_if_net_down()
  ret <- bcdc_list()
  expect_is(ret, "character")
  expect_gt(length(ret), 1000)
})

test_that("bcdc_search works", {
  skip_on_cran()
  skip_if_net_down()
  expect_is(bcdc_search("forest"), "bcdc_recordlist")
  expect_is(bcdc_search("regional district",
                        type = "Geographic", res_format = "fgdb"),
            "bcdc_recordlist")
  expect_error(bcdc_search(organization = "foo"),
               "foo is not a valid value for organization")
})

test_that("a record with bcgeographicwarehouse AND wms is return by bcdc_get_record",{
  skip_on_cran()
  sr <- bcdc_get_record('95da1091-7e8c-4aa6-9c1b-5ab159ea7b42')
  d <- sr$resource_df
  expect_true(d$bcdata_available[d$location == "bcgeographicwarehouse" & d$format == "wms"])
})

test_that("a record with bcgeographicwarehouse AND wms is return by bcdc_get_record",{
  skip_on_cran()
  sr <- bcdc_get_record('76b1b7a3-2112-4444-857a-afccf7b20da8')
  d <- sr$resource_df
  expect_false(all(d$bcdata_available[d$location == "bcgeographicwarehouse" & d$format != "wms"]))
  })
