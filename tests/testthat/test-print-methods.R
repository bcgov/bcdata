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

test_that("bcdc_promise print methods work", {
  skip_on_cran()
  skip_if_net_down()
  promise_print <- capture_output(
    bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8'),
    print = TRUE
  )
  expect_true(nzchar(promise_print))
})

test_that("bcdc_record print methods work", {
  skip_on_cran()
  skip_if_net_down()
  record_print <- capture_output(
    bcdc_get_record('76b1b7a3-2112-4444-857a-afccf7b20da8'),
    print = TRUE
  )
  expect_true(nzchar(record_print))
})

test_that("bcdc_recordlist print methods work", {
  skip_on_cran()
  skip_if_net_down()
  recordlist_print <- capture_output(bcdc_search("bears"), print = TRUE)
  expect_true(nzchar(recordlist_print))
})

test_that("show query works for bcdc_promise object", {
  skip_on_cran()
  skip_if_net_down()
  prom_obj <- bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8')
  expect_s3_class(show_query(prom_obj), "bcdc_query")
})


test_that("show query works for bcdc_sf object", {
  skip_on_cran()
  skip_if_net_down()
  sf_obj <- collect(bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8'))
  expect_s3_class(show_query(sf_obj), "bcdc_query")
})

test_that("record with a zip file prints correctly", {
  skip_on_cran()
  skip_if_net_down()
  output <- capture_output(
    bcdc_get_record("bc-grizzly-bear-habitat-classification-and-rating"),
    print = TRUE
  )
  expect_true(any(grepl("zip", output)))
})
