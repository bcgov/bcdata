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

test_that('bcdc_search subsetting works', {
  skip_on_cran()
  skip_if_net_down()
  rec_list <- bcdc_search("Container", n = 5)
  expect_s3_class(rec_list, "bcdc_recordlist")
  expect_length(rec_list, 5)
  shorter <- rec_list[3:5]
  expect_s3_class(shorter, "bcdc_recordlist")
  expect_length(shorter, 3)
})

test_that("process_search_terms works", {
  terms <- process_search_terms("a", "b", "c")
  expect_equal(terms, "a+b+c")
  expect_error(process_search_terms(a = "one"), "should not be named")
})

test_that("bcdc_search works with zero results", {
  skip_on_cran()
  skip_if_net_down()

  res <- bcdc_search("foobarbananas")
  expect_s3_class(res, "bcdc_recordlist")
  expect_length(res, 0L)

  expect_output(print(res), "returned no results")
})

test_that('bcdc_search_facets works', {
  skip_on_cran()
  skip_if_net_down()
  orgs <- bcdc_search_facets("organization")
  grps <- bcdc_search_facets("groups")
  licences <- bcdc_search_facets("license_id")
  expect_s3_class(orgs, "data.frame")
  expect_s3_class(grps, "data.frame")
  expect_s3_class(licences, "data.frame")
  expect_gte(nrow(orgs), 1)
  expect_gte(nrow(grps), 1)
  expect_gte(nrow(licences), 1)
})

test_that('bcdc_list_group_records works', {
  skip_on_cran()
  skip_if_net_down()
  census <- bcdc_list_group_records("census-profiles")
  grps <- bcdc_search_facets("groups")
  census_count <- grps |>
    dplyr::filter(name == "census-profiles") |>
    dplyr::pull(count)
  expect_s3_class(census, "data.frame")
  expect_gte(nrow(census), 1)
  expect_equal(nrow(census), census_count)
})

test_that('bcdc_list_organization_records works', {
  skip_on_cran()
  skip_if_net_down()
  bcstats <- bcdc_list_organization_records("bc-stats")
  orgs <- bcdc_search_facets("organization")
  bcstats_count <- orgs |>
    dplyr::filter(name == "bc-stats") |>
    dplyr::pull(count)
  expect_s3_class(bcstats, "data.frame")
  expect_gte(nrow(bcstats), 1)
  expect_equal(nrow(bcstats), bcstats_count)
})
