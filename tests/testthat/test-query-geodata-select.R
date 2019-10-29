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

context("testing ability of select methods to narrow a wfs query")

test_that("select doesn't remove the geometry column",{
  skip_if_net_down()
  skip_on_cran()
  gw_wells <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    select(SOURCE_ACCURACY) %>%
    collect()
  expect_false(st_is_empty(gw_wells$geometry))
})

test_that("select works when selecting a column that isn't sticky",{
  skip_if_net_down()
  skip_on_cran()
  one_well <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    select(FCODE) %>%
    collect()

  expect_true("FCODE" %in% names(one_well))
})


test_that("select reduces the number of columns when a sticky ",{
  skip_if_net_down()
  skip_on_cran()
  feature_spec <- bcdc_describe_feature("ground-water-wells")
  ## Columns that can selected, while manually including GEOMETRY col
  sticky_cols <- c(
    feature_spec[feature_spec$selectable != TRUE,]$col_name,
    "geometry")

  sub_cols <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    select(WELL_ID) %>%
    collect()

  expect_identical(names(sub_cols), sticky_cols)
})

test_that("select works with BCGW name", {
  skip_on_cran()
  skip_if_net_down()
  expect_silent(ret <- bcdc_query_geodata("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW") %>%
                  select(AIRPORT_NAME, DESCRIPTION) %>%
                  collect())
})
