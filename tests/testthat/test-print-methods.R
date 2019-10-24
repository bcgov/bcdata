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

context("testprint methods")

test_that("bcdc_promise print methods work",{
  promise_print <- capture_output(bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8'), print = TRUE)
  expect_equal(substr(promise_print, 1, 100), "Querying 'bc-airports' record\n* Using collect() on this object will return 455 features and 41 field")
})

test_that("bcdc_record print methods work",{
  record_print <- capture_output(bcdc_get_record('76b1b7a3-2112-4444-857a-afccf7b20da8'), print = TRUE)
  expect_equal(substr(record_print, 1, 100), "B.C. Data Catalogue Record:\n    BC Airports \n\nName: bc-airports (ID: 76b1b7a3-2112-4444-857a-afccf7b")
})


test_that("bcdc_recordlist print methods work",{
  skip_on_cran() ## this test feels a bit fragile and therefore skipping on CRAN to avoid spurious failures
  recordlist_print <- capture_output(bcdc_list(), print = TRUE)
  expect_equal(substr(recordlist_print, 1, 100), "  [1] \"fire-perimeters-current\"                                                  \n  [2] \"coalfile-da")
})

test_that("show query works for bcdc_promise object",{
  prom_obj <- bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8')
  expect_true(show_query(prom_obj))
})


test_that("show query works for bcdc_sf object",{
  sf_obj <- collect(bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8'))
  expect_true(show_query(sf_obj))
})
