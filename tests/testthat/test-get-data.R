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

context("testing ability of bcdc_get_data to retrieve a valid object")

test_that("bcdc_get_data collects an sf object for a valid record and resource id", {
  skip_if_net_down()
  skip_on_cran()
  bc_airports <- bcdc_get_data('76b1b7a3-2112-4444-857a-afccf7b20da8',
                               resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c")
  expect_is(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})


test_that("bcdc_get_data works with slug and full url with corresponding resource", {
  skip_if_net_down()
  skip_on_cran()
  expect_is(ret1 <- bcdc_get_data("https://catalogue.data.gov.bc.ca/dataset/bc-airports", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")
  expect_is(ret2 <- bcdc_get_data("bc-airports", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")
  expect_is(ret3 <- bcdc_get_data("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")
  expect_is(ret4 <- bcdc_get_data("76b1b7a3-2112-4444-857a-afccf7b20da8", resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")
  expect_is(ret5 <- bcdc_get_data("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8/resource/4d0377d9-e8a1-429b-824f-0ce8f363512c"),
            "sf")

  for (x in list(ret2, ret3, ret4, ret5)) {
    expect_equal(dim(x), dim(ret1))
    expect_equal(names(x), names(ret1))
  }
})


test_that("bcdc_get_data works with a non-wms record with only one resource",{
  skip_if_net_down()
  skip_on_cran()
  name <- "ee9d4ee0-6a34-4dff-89e0-9add9a969168" # "criminal-code-traffic-offences"
  expect_is(bcdc_get_data(name), "tbl")
})

test_that("bcdc_get_data works when using read_excel arguments", {
  skip_if_net_down()
  skip_on_cran()
  ret <- bcdc_get_data("2e469ff2-dadb-45ea-af9d-f5683a4b9465",
                       resource = "18510a60-de82-440a-b806-06fba70eaf9d",
                       skip = 4, n_max = 3)
  expect_is(ret, "tbl")
  expect_equivalent(nrow(ret), 3L)
})

test_that("bcdc_get_data works with an xls when specifying a specific resource",{
  skip_if_net_down()
  skip_on_cran()
  name <- 'bc-grizzly-bear-habitat-classification-and-rating'
  expect_is(bcdc_get_data(name, resource = '7b09f82f-e7d0-44bf-9310-b94039b323a8'), "tbl")
})

test_that("bcdc_get_data will return non-wms resources",{
  skip_if_net_down()
  skip_on_cran()
  expect_is(bcdc_get_data(record = '76b1b7a3-2112-4444-857a-afccf7b20da8',
                 resource = 'fcccba36-b528-4731-8978-940b3cc04f69'), "tbl")

  expect_is(bcdc_get_data(record = 'fa542137-a976-49a6-856d-f1201adb2243',
                          resource = 'dc1098a7-a4b8-49a3-adee-9badd4429279'), "tbl")
})

test_that("bcdc_get_data works with a zipped shp file", {
  skip_if_net_down()
  skip_on_cran()
  expect_is(bcdc_get_data(record = '481d6d4d-a536-4df9-9e9c-7473cd2ed89e',
                          resource = '41c9bff0-4e25-49fc-a3e2-2a2e426ac71d'),
            "sf")
})

test_that("unknown single file (shp) inside zip", {
  skip_if_net_down()
  skip_on_cran()
  expect_is(bcdc_get_data("e31f7488-27fa-4330-ae86-160a0deb8a59"),
            "sf")
})

test_that("fails when resource doesn't exist", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(bcdc_get_data("300c0980-b5e3-4202-b0da-d816f14fadad",
                             resource = "not-a-real-resource"),
               "The specified resource does not exist in this record")
})

test_that("fails when multiple files in a zip", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(bcdc_get_data("300c0980-b5e3-4202-b0da-d816f14fadad",
                             resource = "c212a8a7-c625-4464-b9c8-4527c843f52f"),
               "More than one supported file in zip file")
})

test_that("fails informatively when can't read a file", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(
    suppressWarnings(
      bcdc_get_data(record = '523dce9d-b464-44a5-b733-2022e94546c3',
                             resource = '4cc98644-f6eb-410b-9df0-f9b2beac9717')
      ),
    "Reading the data set failed with the following error message:")
})

test_that("bcdc_get_data can return the wms resource when it is specified by resource",{
  skip_if_net_down()
  skip_on_cran()
  expect_is(bcdc_get_data('76b1b7a3-2112-4444-857a-afccf7b20da8',
                          resource = "4d0377d9-e8a1-429b-824f-0ce8f363512c"), "sf")
})


test_that("a wms record with only one resource works with only the record id",{
  skip_if_net_down()
  skip_on_cran()
  expect_is(bcdc_get_data("bc-college-region-boundaries"), "sf")
  })

test_that("bcdc_get_data works with a bcdc_record object", {
  skip_if_net_down()
  skip_on_cran()
  record <- bcdc_get_record("bc-college-region-boundaries")
  expect_is(bcdc_get_data(record), "sf")

  record <- bcdc_get_record('fa542137-a976-49a6-856d-f1201adb2243')
  expect_is(bcdc_get_data(record,
                          resource = 'dc1098a7-a4b8-49a3-adee-9badd4429279'),
            "tbl")
})

test_that("bcdc_get_data fails with invalid input", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(bcdc_get_data(35L),
               "No bcdc_get_data method for an object of class integer")
})

test_that("bcdc_get_data works with BCGW name", {
  skip_if_net_down()
  skip_on_cran()
  expect_is(bcdc_get_data("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW"), "bcdc_sf")
})

test_that("bcdc_get_data fails when no downloadable resources", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(bcdc_get_data("4e237966-3db8-4e28-8e59-296bf0b8d8e4"),
               "There are no resources that bcdata can download from this record")
})

test_that("bcdc_get_data fails when >1 resource not specified & noninteractive", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(bcdc_get_data("21c72822-2502-4431-b9a2-92fc9401ef12"),
               "The record you are trying to access appears to have more than one resource.")
})

test_that("bcdc_get_data handles sheet name specification", {
  skip_if_net_down()
  skip_on_cran()
  expect_message(bcdc_get_data('8620ce82-4943-43c4-9932-40730a0255d6'), 'This .xlsx resource contains the following sheets:')
  expect_error(bcdc_get_data('8620ce82-4943-43c4-9932-40730a0255d6', sheet = "foo"), "Error: Sheet 'foo' not found")
  out <- capture.output(bcdc_get_data('8620ce82-4943-43c4-9932-40730a0255d6', sheet = "Notes"), type = 'message')
  expect_false(any(grepl('This .xlsx resource contains the following sheets:', out)))
})

test_that("bcdc_get_data returns a list object when resource has a json extension", {
  skip_if_net_down()
  skip_on_cran()
  expect_type(bcdc_get_data("8e24f2bc-ab7a-49df-9418-539387180f33"), "list")
})
