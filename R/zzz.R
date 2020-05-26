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

bcdata_env <- new.env(parent = emptyenv())

.onLoad <- function(...) {
 assign("named_get_record_warned", FALSE, envir = bcdata_env) # nocov
}

# Define bcdc_sf as a subclass of sf so that it works
# with S4 methods for sf (eg mapview)
methods::setOldClass(c("bcdc_sf", "sf"))
