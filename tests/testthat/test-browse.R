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

context("confirm browsing ability")

test_that("bcdc_get_geodata returns an sf object for a valid id", {
  skip_if_net_down()
  forest_url <- bcdc_browse("forest")
  expect_identical(forest_url, "https://catalogue.data.gov.bc.ca/dataset?q=forest")
  catalogue_url <- bcdc_browse()
  expect_identical(catalogue_url, "https://catalogue.data.gov.bc.ca")

})
