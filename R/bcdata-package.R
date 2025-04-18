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

#' @keywords internal
#'
"_PACKAGE"

#' @importFrom cli cat_rule cat_line cat_bullet col_blue col_red col_green
#' @importFrom methods setOldClass
NULL

release_bullets <- function() {
  c(
    "Run test and check with internet turned off",
    "Precompile vignettes"
  )
}
