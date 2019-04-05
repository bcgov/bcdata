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

context("Testing bcdc_describe_feature function")

test_that("Test that bcdc_describe feature returns the correct columns",{
  airport_feature <- bcdc_describe_feature("bc-airports")
  expect_identical(names(airport_feature), c("col_name", "nillable", "col_type"))
})
