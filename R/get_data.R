# Copyright 2018 Province of British Columbia
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

bcdc_get_data <- function(record, res_id = NULL) {
  # record can be either a url/slug or a bcdata_record
  if (interactive() && is.null(res_id)) {
    # print numbered list of resources for use to choose from
    res_id <- menu("pick a resource")
  }
  get_data(record, res_id)
}
