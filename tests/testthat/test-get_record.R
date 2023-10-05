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

test_that("bcdc_get_record works with slug and full url", {
  skip_on_cran()
  skip_if_net_down()
  expect_s3_class(ret1 <- bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/bc-airports"),
           "bcdc_record")
  expect_s3_class(ret2 <- bcdc_get_record("bc-airports"),
           "bcdc_record")
  expect_s3_class(ret3 <- bcdc_get_record("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8"),
           "bcdc_record")
  expect_s3_class(ret4 <- bcdc_get_record("76b1b7a3-2112-4444-857a-afccf7b20da8"),
           "bcdc_record")
  expect_equal(ret1$title, "BC Airports")
  lapply(list(ret2, ret3, ret4), expect_equal, ret1)
})

test_that("bcdc_search_facets works", {
  skip_on_cran()
  skip_if_net_down()
  ret_names <- c("facet", "count", "display_name", "name")
  lapply(c("license_id", "download_audience", "res_format",
           "sector", "organization"),
         function(x) expect_named(bcdc_search_facets(x))
  )
  expect_error(bcdc_search_facets("foo"), "'arg' should be one of")
})


test_that("bcdc_list_group_records works", {
  skip_on_cran()
  skip_if_net_down()

  expect_s3_class(bcdc_list_group_records('environmental-reporting-bc'), "bcdc_group")
  expect_s3_class(bcdc_list_group_records('environmental-reporting-bc'), "tbl_df")

})

test_that("bcdc_list_groups", {
  skip_on_cran()
  skip_if_net_down()

  expect_s3_class(bcdc_list_groups(), "data.frame")
})

test_that("bcdc_list_organization_records works", {
  skip_on_cran()
  skip_if_net_down()

  expect_s3_class(bcdc_list_organization_records('bc-stats'), "bcdc_organization")
  expect_s3_class(bcdc_list_organization_records('bc-stats'), "tbl_df")

})

test_that("bcdc_list_organizations", {
  skip_on_cran()
  skip_if_net_down()

  expect_s3_class(bcdc_list_organizations(), "data.frame")
})

test_that("bcdc_list works", {
  skip_on_cran()
  skip_if_net_down()
  ret <- bcdc_list()
  expect_type(ret, "character")
  expect_gt(length(ret), 1000)
})

test_that("bcdc_search works", {
  skip_on_cran()
  skip_if_net_down()
  expect_s3_class(bcdc_search("forest"), "bcdc_recordlist")
  expect_s3_class(bcdc_search("regional district", res_format = "fgdb"),
            "bcdc_recordlist")
  expect_error(bcdc_search(organization = "foo"),
               "foo is not a valid value for organization")
})

test_that("a record with bcgeographicwarehouse AND wms is return by bcdc_get_record",{
  skip_on_cran()
  skip_if_net_down()
  sr <- bcdc_get_record('95da1091-7e8c-4aa6-9c1b-5ab159ea7b42')
  d <- sr$resource_df
  expect_true(d$bcdata_available[d$location == "bcgeographicwarehouse" & d$format == "wms"])
})

test_that("a record with bcgeographicwarehouse AND wms is return by bcdc_get_record",{
  skip_on_cran()
  skip_if_net_down()
  sr <- bcdc_get_record('76b1b7a3-2112-4444-857a-afccf7b20da8')
  d <- sr$resource_df
  expect_false(all(d$bcdata_available[d$location == "bcgeographicwarehouse" & d$format != "wms"]))
  })


test_that("a data frame with 8 columns of expected types is returned by bcdc_tidy_resources",{
  skip_if_net_down()
  skip_on_cran()
  sr <- bcdc_get_record('76b1b7a3-2112-4444-857a-afccf7b20da8')
  d <- bcdc_tidy_resources(sr)
  expect_s3_class(d, "data.frame")
  expect_true(ncol(d) == 9)
  expect_type(d$name, "character")
  expect_type(d$url, "character")
  expect_type(d$id, "character")
  expect_type(d$format, "character")
  expect_type(d$ext, "character")
  expect_type(d$package_id, "character")
  expect_type(d$location, "character")
  expect_type(d$wfs_available, "logical")
  expect_type(d$bcdata_available, "logical")
  expect_equal(d, bcdc_tidy_resources('76b1b7a3-2112-4444-857a-afccf7b20da8'))
  expect_error(bcdc_tidy_resources(list()), "No bcdc_tidy_resources method for an object of class")
  expect_error(bcdc_tidy_resources("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW"),
               "No bcdc_tidy_resources method for a BCGW object name")
})

test_that("bcdc_get_record works with/without authentication", {
  skip_if_net_down()
  skip_on_cran()

  key_val <- Sys.getenv("BCDC_KEY")
  skip_if_not(nzchar(key_val))
  on.exit(Sys.setenv(BCDC_KEY = key_val))

  # record NOT requiring auth
  expect_message(res <- bcdc_get_record(point_record),
                 "Authorizing with your stored API key")
  expect_s3_class(res, "bcdc_record")

  # record requiring auth
  auth_record_id <- Sys.getenv("BCDC_TEST_RECORD")
  skip_if_not(nzchar(key_val))

  expect_message(res <- bcdc_get_record(auth_record_id),
                 "Authorizing with your stored API key")
  expect_s3_class(res, "bcdc_record")

  Sys.unsetenv("BCDC_KEY")

  # record NOT requiring auth
  expect_silent(bcdc_get_record(point_record))

  # record requiring auth (with no key set)
  expect_error(bcdc_get_record(auth_record_id))

  # record requiring auth (with bad key set)
  Sys.setenv(BCDC_KEY = "not-a-valid-key")
  expect_error(bcdc_get_record(auth_record_id))
})
