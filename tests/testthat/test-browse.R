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

test_that("bcdc_browse returns the correct url", {
  skip_if_net_down()
  skip_on_cran()
  airports_url <- bcdc_browse("bc-airports")
  expect_identical(
    airports_url,
    paste0(catalogue_base_url(), "dataset/bc-airports")
  )
  catalogue_url <- bcdc_browse()
  expect_identical(catalogue_url, catalogue_base_url())
  expect_error(
    bcdc_browse("no-record-here"),
    "The specified record does not exist in the catalogue"
  )
})
