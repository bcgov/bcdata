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

test_that("bcdc_options() returns a tibble", {
  skip_if_net_down()
  skip_on_cran()
  opts <- bcdc_options()
  expect_s3_class(opts, "tbl_df")
})

test_that("bcdata.chunk_limit", {
  skip_if_net_down()
  skip_on_cran()
  withr::with_options(list(bcdata.chunk_limit = 100000), {
    expect_error(check_chunk_limit())
  })
  withr::with_options(list(bcdata.chunk_limit = 10), {
    expect_true(is.numeric(check_chunk_limit()))
    expect_equal(check_chunk_limit(), 10)
  })
})

test_that("bcdata.max_package_search_limit works", {
  skip_if_net_down()
  skip_on_cran()
  withr::with_options(list(bcdata.max_package_search_limit = 10), {
    bcstats <- bcdc_list_organization_records("bc-stats")
    expect_lte(nrow(bcstats), 10)
  })
})

test_that("bcdata.max_package_search_facet_limit works", {
  skip_if_net_down()
  skip_on_cran()
  withr::with_options(list(bcdata.max_package_search_facet_limit = 10), {
    orgs <- bcdc_search_facets("organization")
    expect_lte(nrow(orgs), 10)
  })
})

test_that("bcdata.max_group_package_show_limit works", {
  skip_if_net_down()
  skip_on_cran()
  withr::with_options(list(bcdata.max_group_package_show_limit = 10), {
    census <- bcdc_list_group_records("census-profiles")
    expect_lte(nrow(census), 10)
  })
})

test_that("bcdata.single_download_limit is deprecated but works", {
  # This can be removed when bcdata.single_download_limit is removed
  skip_if_net_down()
  skip_on_cran()
  withr::local_options(list(bcdata.single_download_limit = 1))
  withr::local_envvar(list(BCDC_KEY = NULL)) # so snapshot not affected by message
  expect_s3_class(
    bcdc_query_geodata(record = '76b1b7a3-2112-4444-857a-afccf7b20da8'),
    "bcdc_promise"
  )
})

test_that("bcdata.single_download_limit can be changed", {
  # This can be removed when bcdata.single_download_limit is removed
  skip_if_net_down()
  skip_on_cran()
  withr::local_options(list(bcdata.single_download_limit = 13))
  expect_equal(getOption("bcdata.single_download_limit"), 13)
})

test_that("bcdc_single_download_limit returns a number", {
  skip_on_cran()
  skip_if_net_down()
  lt <- bcdc_single_download_limit()
  expect_type(lt, "integer")
})
