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
  original_value <- getOption("bcdata.chunk_limit")
  options(bcdata.chunk_limit = 10000)
  expect_error(check_chunk_limit())

  ## cleaning up. not sure if this is required but likely not a bad practice.
  options(bcdata.chunk_limit = original_value)

})
