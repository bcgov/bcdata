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

test_that("bcdc_query_geodata collects an sf object for a valid id", {
  skip_on_cran()
  skip_if_net_down()
  bc_airports <- bcdc_query_geodata("bc-airports") %>% collect()
  expect_s3_class(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})

test_that("bcdc_query_geodata collects using as_tibble", {
  skip_on_cran()
  skip_if_net_down()
  bc_airports <- bcdc_query_geodata("bc-airports") %>% as_tibble()
  expect_s3_class(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})

test_that("bcdc_query_geodata succeeds with a records over 10000 rows", {
  skip_on_cran()
  skip_if_net_down()
  skip("Skipping the BEC test, though available for testing")
  expect_s3_class(
    collect(
      bcdc_query_geodata(
        "terrestrial-protected-areas-representation-by-biogeoclimatic-unit"
      )
    ),
    "bcdc_sf"
  )
})


test_that("bcdc_query_geodata works with slug and full url using collect", {
  skip_on_cran()
  skip_if_net_down()
  expect_s3_class(
    ret1 <- bcdc_query_geodata(
      glue::glue("{catalogue_base_url()}/dataset/bc-airports")
    ) %>%
      collect(),
    "sf"
  )
  expect_s3_class(
    ret2 <- bcdc_query_geodata("bc-airports") %>% collect(),
    "sf"
  )
  expect_s3_class(
    ret3 <- bcdc_query_geodata(
      glue::glue(
        "{catalogue_base_url()}/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8"
      )
    ) %>%
      collect(),
    "sf"
  )
  expect_s3_class(
    ret4 <- bcdc_query_geodata("76b1b7a3-2112-4444-857a-afccf7b20da8") %>%
      collect(),
    "sf"
  )
  expect_s3_class(
    ret5 <- bcdc_query_geodata(
      glue::glue(
        "{catalogue_base_url()}/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8/resource/4d0377d9-e8a1-429b-824f-0ce8f363512c"
      )
    ) %>%
      collect(),
    "sf"
  )

  for (x in list(ret2, ret3, ret4, ret5)) {
    expect_equal(dim(x), dim(ret1))
    expect_equal(names(x), names(ret1))
  }
})


test_that("bcdc_query_geodata works with spatial data that have SHAPE for the geom", {
  ## View metadata to see that geom is SHAPE
  ## bcdc_browse("bc-wildfire-fire-perimeters-historical")
  skip_on_cran()
  skip_if_net_down()
  crd <- bcdc_query_geodata(
    "regional-districts-legally-defined-administrative-areas-of-bc"
  ) %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()

  ret1 <- suppressWarnings(
    bcdc_query_geodata("22c7cb44-1463-48f7-8e47-88857f207702") %>%
      filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
      collect()
  )
  expect_s3_class(ret1, "sf")
})

test_that("collect() returns a bcdc_sf object", {
  skip_on_cran()
  skip_if_net_down()
  sf_obj <- bcdc_query_geodata("76b1b7a3-2112-4444-857a-afccf7b20da8") %>%
    filter(LOCALITY == "Terrace") %>%
    select(LATITUDE) %>%
    collect()
  expect_s3_class(sf_obj, "bcdc_sf")
})

test_that("bcdc_sf objects has attributes", {
  skip_on_cran()
  skip_if_net_down()
  sf_obj <- bcdc_query_geodata("76b1b7a3-2112-4444-857a-afccf7b20da8") %>%
    filter(LOCALITY == "Terrace") %>%
    select(LATITUDE) %>%
    collect()

  expect_identical(
    names(attributes(sf_obj)),
    c(
      "names",
      "row.names",
      "class",
      "sf_column",
      "agr",
      "query_list",
      "url",
      "full_url",
      "time_downloaded"
    )
  )
  expect_true(nzchar(attributes(sf_obj)$url))
  expect_true(nzchar(attributes(sf_obj)$full_url))
  expect_s3_class(attributes(sf_obj)$time_downloaded, "POSIXt")
})
