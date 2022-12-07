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
  feat <- bcdc_query_geodata(point_record) %>%
    filter(SOURCE_DATA_ID == 455) %>%
    select(SOURCE_DATA_ID) %>%
    collect()
  expect_s3_class(feat, "bcdc_sf")
})

test_that("select works when selecting a column that isn't sticky",{
  skip_if_net_down()
  skip_on_cran()
  feat <- bcdc_query_geodata(point_record) %>%
    filter(LOCALITY == 'Terrace') %>%
    select(DESCRIPTION) %>%
    collect()

  expect_true("DESCRIPTION" %in% names(feat))
})


test_that("select reduces the number of columns when a sticky ",{
  skip_if_net_down()
  skip_on_cran()
  feature_spec <- bcdc_describe_feature(point_record)
  ## Columns that can selected, while manually including GEOMETRY col
  sticky_cols <- c(
    feature_spec[feature_spec$sticky,]$col_name,
    "geometry")

  sub_cols <- bcdc_query_geodata(point_record) %>%
    select(BUSINESS_CATEGORY_CLASS) %>%
    collect()

  expect_identical(names(sub_cols), sticky_cols)
})

test_that("select works with BCGW name", {
  skip_on_cran()
  skip_if_net_down()
  expect_silent(ret <- bcdc_query_geodata(bcgw_point_record) %>%
                  select(AIRPORT_NAME, DESCRIPTION) %>%
                  collect())
})


test_that("select accept dplyr like column specifications",{
  skip_if_net_down()
  skip_on_cran()
  layer <-  bcdc_query_geodata(polygon_record)
  wrong_fields <-  c('ADMIN_AREA_NAME', 'dummy_col')
  correct_fields <-  c('ADMIN_AREA_NAME', 'OIC_MO_YEAR')


  ## Most basic select
  expect_is(select(layer, ADMIN_AREA_NAME, OIC_MO_YEAR), "bcdc_promise")
  ## Using a pre-assigned vector
  expect_is(select(layer, all_of(correct_fields)), "bcdc_promise")
  ## Throws an error when column doesn't exist
  expect_error(select(layer, all_of(wrong_fields)))
  expect_is(select(layer, ADMIN_AREA_NAME:OIC_MO_YEAR), "bcdc_promise")
  ## Some weird mix
  expect_is(select(layer, 'ADMIN_AREA_NAME', OIC_MO_YEAR), "bcdc_promise")
  ## Another weird mix
  expect_is(select(layer, c('ADMIN_AREA_NAME','OIC_MO_YEAR') , OIC_MO_NUMBER), "bcdc_promise")
  expect_is(select(layer, 1:5), "bcdc_promise")
})
