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

if (has_internet() && identical(Sys.getenv("NOT_CRAN"), "true")) {
  local <- bcdc_query_geodata(
    "regional-districts-legally-defined-administrative-areas-of-bc"
  ) %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()
}

test_that("bcdc_check_geom_size outputs message with low threshold", {
  skip_on_cran()
  skip_if_net_down()

  withr::local_options(list(bcdata.max_geom_pred_size = 1))
  expect_message(bcdc_check_geom_size(local), "The object is too large")
  expect_false(bcdc_check_geom_size(local))
})

test_that("bcdc_check_geom_size is silent with high threshold", {
  skip_on_cran()
  skip_if_net_down()

  withr::local_options(list(bcdata.max_geom_pred_size = 1E10))
  expect_true(bcdc_check_geom_size(local))
})


test_that("WITHIN works", {
  skip_on_cran()
  skip_if_net_down()

  remote <- suppressWarnings(
    bcdc_query_geodata("bc-airports") %>%
      filter(WITHIN(local)) %>%
      collect()
  )

  expect_s3_class(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
})


test_that("INTERSECTS works", {
  skip_on_cran()
  skip_if_net_down()

  remote <- suppressWarnings(
    bcdc_query_geodata("bc-parks-ecological-reserves-and-protected-areas") %>%
      filter(FEATURE_LENGTH_M <= 1000, INTERSECTS(local)) %>%
      collect()
  )

  expect_s3_class(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
})

test_that("RELATE works", {
  skip("RELATE not supported. https://github.com/bcgov/bcdata/pull/154")
  skip_on_cran()
  skip_if_net_down()

  remote <- suppressWarnings(
    bcdc_query_geodata("bc-parks-ecological-reserves-and-protected-areas") %>%
      filter(RELATE(local, "*********")) %>%
      collect()
  )

  expect_s3_class(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
})

test_that("DWITHIN works", {
  skip_on_cran()
  skip_if_net_down()

  remote <- suppressWarnings(
    bcdc_query_geodata("bc-parks-ecological-reserves-and-protected-areas") %>%
      filter(DWITHIN(local, 100, "meters")) %>%
      collect()
  )

  expect_s3_class(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
})

test_that("BEYOND works", {
  skip("BEYOND currently not supported")
  # https://osgeo-org.atlassian.net/browse/GEOS-8922
  skip_on_cran()
  skip_if_net_down()

  remote <- suppressWarnings(
    bcdc_query_geodata("bc-parks-ecological-reserves-and-protected-areas") %>%
      filter(BEYOND(local, 100, "meters")) %>%
      collect()
  )

  expect_s3_class(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
})

test_that("BBOX works with an sf bbox", {
  skip_on_cran()
  skip_if_net_down()

  remote <- suppressWarnings(
    bcdc_query_geodata("bc-parks-ecological-reserves-and-protected-areas") %>%
      filter(FEATURE_LENGTH_M <= 1000, BBOX(!!sf::st_bbox(local))) %>%
      collect()
  )

  expect_s3_class(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
})


test_that("BBOX works with an sf object", {
  skip_on_cran()
  skip_if_net_down()

  remote <- suppressWarnings(
    bcdc_query_geodata("bc-parks-ecological-reserves-and-protected-areas") %>%
      filter(FEATURE_LENGTH_M <= 1000, BBOX(local)) %>%
      collect()
  )

  expect_s3_class(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
})

test_that("Other predicates work with an sf bbox", {
  skip_on_cran()
  skip_if_net_down()

  remote <- suppressWarnings(
    bcdc_query_geodata("bc-parks-ecological-reserves-and-protected-areas") %>%
      filter(FEATURE_LENGTH_M <= 1000, INTERSECTS(!!sf::st_bbox(local))) %>%
      collect()
  )

  expect_s3_class(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
})
