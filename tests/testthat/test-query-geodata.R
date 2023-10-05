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

test_that("bcdc_query_geodata returns an bcdc_promise object for a valid id OR bcdc_record", {
  skip_on_cran()
  skip_if_net_down()
  # id (character)
  bc_airports <- bcdc_query_geodata("bc-airports")
  expect_s3_class(bc_airports, "bcdc_promise")

  # bcdc_record
  bc_airports_record <- bcdc_get_record("bc-airports")
  bc_airports2 <- bcdc_query_geodata(bc_airports_record)
  expect_equal(bc_airports, bc_airports2)

  # neither character nor bcdc_record
  expect_error(bcdc_query_geodata(1L),
               "No bcdc_query_geodata method for an object of class integer")
})

test_that("bcdc_query_geodata returns an object with a query, a cli, the catalogue object, and a df of column names",{
  skip_if_net_down()
  skip_on_cran()
  bc_airports <- bcdc_query_geodata("bc-airports")
  expect_type(bc_airports[["query_list"]], "list")
  expect_s3_class(bc_airports[["cli"]], "HttpClient")
  expect_s3_class(bc_airports[["record"]], "bcdc_record")
  expect_s3_class(bc_airports[["cols_df"]], "data.frame")
})


test_that("bcdc_query_geodata returns an object with bcdc_promise class when using filter",{
  skip_on_cran()
  skip_if_net_down()
  bc_eml <- bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
    filter(PERMIT_RELATIONSHIP == "DISCHARGE")
  expect_s3_class(bc_eml, "bcdc_promise")
})


test_that("bcdc_query_geodata returns an object with bcdc_promise class on record under 10000",{
  skip_on_cran()
  skip_if_net_down()
  airports <- bcdc_query_geodata("bc-airports")
  expect_s3_class(airports, "bcdc_promise")
})

test_that("bcdc_query_geodata fails when >1 record", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(bcdc_query_geodata(c("bc-airports", "bc-environmental-monitoring-locations")),
               "Only one record my be queried at a time")
})

test_that("bcdc_query_geodata fails when no wfs available", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(bcdc_query_geodata("dba6c78a-1bc1-4d4f-b75c-96b5b0e7fd30"),
               "No Web Feature Service resource available")
})
