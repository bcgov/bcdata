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



bcdc_get_dem <- function(bbox) {

  if (inherits(bbox, "bbox")) {
    bbox <- paste(bbox, collapse = ",")
  }

  query_list <- list(
    service="WCS",
    version="1.0.0",
    request="GetCoverage",
    coverage="pub:bc_elevation_25m_bcalb",
    bbox=bbox,
    CRS="EPSG:3005",
    RESPONSE_CRS = "EPSG:3005",
    Format="GeoTIFF",
    resx=25,
    resy=25
  )

  ## Drop any NULLS from the list
  query_list <- compact(query_list)

  ## GET and parse data to sf object
  cli <- bcdc_http_client(url = "https://delivery.openmaps.gov.bc.ca/om/wcs")



  tiff_file <- tempfile(fileext = ".tif")
  res <- cli$get(query = query_list, disk = tiff_file)
  close(file(tiff_file))

  raster::raster(res$content)
}
