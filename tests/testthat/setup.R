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

original_options <- options()

options("silence_named_get_record_warning" = TRUE)

##### To test on delivery/test versions of w[fm]s server change this option
# options("bcdata.web_service_host" = "https://delivery.openmaps.gov.bc.ca")
## OR
options("bcdata.web_service_host" = "https://test.openmaps.gov.bc.ca")


point_record <- '76b1b7a3-2112-4444-857a-afccf7b20da8'
polygon_record <- 'd1aff64e-dbfe-45a6-af97-582b7f6418b9'
lines_record <- '92344413-8035-4c08-b996-65a9b3f62fca'
bcgw_point_record <- 'WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW'
