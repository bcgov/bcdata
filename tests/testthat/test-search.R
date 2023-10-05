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
