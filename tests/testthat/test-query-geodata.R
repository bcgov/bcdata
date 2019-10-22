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

context("testing the output of bcdc_query_geodata")

test_that("bcdc_query_geodata returns an bcdc_promise object for a valid id OR bcdc_record", {
  skip_if_net_down()
  # id (character)
  bc_airports <- bcdc_query_geodata("bc-airports")
  expect_is(bc_airports, "bcdc_promise")

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
  bc_airports <- bcdc_query_geodata("bc-airports")
  expect_equivalent(names(bc_airports), c("query_list", "cli", "record", "cols_df"))
})


test_that("bcdc_query_geodata returns an object with bcdc_promise class when using filter",{
  bc_eml <- bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
    filter(PERMIT_RELATIONSHIP == "DISCHARGE")
  expect_is(bc_eml, "bcdc_promise")
})


test_that("bcdc_query_geodata returns an object with bcdc_promise class on record under 10000",{
  skip_if_net_down()
  airports <- bcdc_query_geodata("bc-airports")
  expect_is(airports, "bcdc_promise")
})
