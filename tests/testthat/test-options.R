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

context("testing options")

test_that("bcdc_options() returns a tibble",{
  opts <- bcdc_options()
  expect_s3_class(opts, "tbl_df")
})


test_that("bcdata.chunk_limit",{
  withr::local_options(list(bcdata.chunk_limit = 10000))
  expect_error(check_chunk_limit())
})

test_that("bcdata.single_download_limit", {
  skip_on_cran()
  withr::local_options(list(bcdata.single_download_limit = 1))
  expect_message(
    bcdc_get_data(record = '76b1b7a3-2112-4444-857a-afccf7b20da8', resource =
                    '4d0377d9-e8a1-429b-824f-0ce8f363512c'),
    "pagination"
  )

})

test_that("bcdata.single_download_limit can be changed",{
  withr::local_options(list(bcdata.single_download_limit = 13))
  expect_equal(getOption("bcdata.single_download_limit"), 13)
})

test_that("bcdc_single_download_limit returns a number",{
  skip_on_cran()
  skip_if_net_down()
  lt <- bcdc_single_download_limit()
  expect_type(lt, "integer")
})
