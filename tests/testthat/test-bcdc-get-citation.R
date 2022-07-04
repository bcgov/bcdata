# Copyright 2021 Province of British Columbia
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

context("Testing bcdc_get_citation function")


test_that("bcdc_get_citation take a character and returns a bibentry",{
  skip_if_net_down()
  skip_on_cran()
  rec <- bcdc_get_record(point_record)
  expect_s3_class(bcdc_get_citation(rec), c("citation", "bibentry"))
  expect_s3_class(bcdc_get_citation(point_record), c("citation", "bibentry"))
  test_url <- paste0("https://catalogue.data.gov.bc.ca/dataset/", point_record)
  expect_s3_class(bcdc_get_citation(test_url), c("citation", "bibentry"))
})
