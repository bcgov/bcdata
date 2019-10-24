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

context("Testing bcdc_describe_feature function")

test_that("Test that bcdc_describe feature returns the correct columns",{
  skip_on_cran()
  airport_feature <- bcdc_describe_feature("bc-airports")
  expect_identical(names(airport_feature), c("col_name", "selectable", "remote_col_type","local_col_type"))
})


test_that("columns are the same as the query", {
  skip_on_cran()
  query <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>% ## just to make the query smaller
    collect()

  description <- bcdc_describe_feature("regional-districts-legally-defined-administrative-areas-of-bc")

  expect_identical(sort(setdiff(names(query), "geometry")),
                   sort(setdiff(unique(description$col_name), "SHAPE"))
  )
})

test_that("bcdc_describe_feature accepts a bcdc_record object", {
  skip_on_cran()
  airports <- bcdc_get_record('76b1b7a3-2112-4444-857a-afccf7b20da8')
  airport_feature <- bcdc_describe_feature(airports)
  expect_identical(names(airport_feature), c("col_name", "selectable", "remote_col_type","local_col_type"))
})

test_that("bcdc_describe_feature accepts BCGW name",{
  skip_on_cran()
  airport_feature <- bcdc_describe_feature("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW")
  expect_identical(names(airport_feature), c("col_name", "selectable", "remote_col_type","local_col_type"))
})

test_that("bcdc_describe_feature fails on unsupported classes", {
  skip_on_cran()
  expect_error(bcdc_describe_feature(1L))
  expect_error(bcdc_describe_feature(list(a = 1)))
})


