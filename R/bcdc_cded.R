# Copyright 2020 Province of British Columbia
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


#' Download Canadian Digital Elevation Data (CDED) intersecting the user provided area of interest. 
#' 
#' This function accepts a user provided area of interest as a sf object and retrieves CDED
#' data for each of the NTS 50K Grid  Digital Baseline Mapping at 1:50,000 (NTS) polygons 
#' that intersect. The CDED data is obtained from \code{"https://pub.data.gov.bc.ca/datasets/175624/"}.
#' The output CDED will be projected to the coordinate reference system of the area of interest provided,
#' and returned as a raster object. 
#' 
#'  @param aoi Area of interest to intersect CDED as sf object. 
#'  @param cdedurl (Optional) Web address to CDED data, defaults to \code{"https://pub.data.gov.bc.ca/datasets/175624/"}.
#'  @param resolution (Optional) If provided, CDED will be resampled to the specified resolution using a bilinear method. 
#'  @return A raster object containing CDED data intersected and projected to area of interest. 
#'  @export
bcdc_cded<-function(aoi,cdedurl="https://pub.data.gov.bc.ca/datasets/175624/",resolution=NULL) 
{
  #Check if the CDED URL can be read
  if(summary(url(cdedurl))[6]=="yes"){
  
  #Record start time for user information.
  start.time <- Sys.time()
  
  #Coordinate Reference System of area of interest sf object.
  aoi_crs <- sf::st_crs(aoi)$proj4string
  
  #Obtain TS 50K Grid  Digital Baseline Mapping at 1:50,000 (NTS) polygons that intersect use area of interest. 
  cat("Retreiving NTS 50K Grid  Digital Baseline Mapping at 1:50,000 (NTS) polygons.")
  grid50k <- bcdata::bcdc_query_geodata("f9483429-fedd-4704-89b9-49fd098d4bdb") %>% 
    bcdata::filter(bcdata::INTERSECTS(aoi)) %>% 
    bcdata::collect()
  
  #Get Mapping URLs.
  cat("\nCreating url list for mapsheet tiles.")
  grid50k$block <- substring(grid50k$MAP_TILE, first = 2, last = 4)
  grid50k$url1 <- paste0(cdedurl, grid50k$block, "/", grid50k$MAP_TILE, "_e.dem.zip")
  grid50k$url2 <- paste0(cdedurl, grid50k$block, "/", grid50k$MAP_TILE, "_w.dem.zip")
  maplist <- c(grid50k$url1, grid50k$url2)
  temp <- tempfile()
  temp2 <- tempfile()
  
  #Counter. 
  x <- 1
  
  #For each mapsheet.
  for (i in maplist) {
    
    #Download the CDED file to temporary directory, unzip, get filename. 
    download.file(i, temp)
    unzip(zipfile = temp, exdir = temp2)
    cat("\nUnzipping ", i, ".")
    filename <- sub("\\.zip$", "", (sapply(strsplit(i, "/"),tail, 1)))
    filename <- tolower(filename)
    
    #Load CDED file as a raster object. 
    if (x == 1) {
      r <- raster::raster(file.path(temp2, filename))
      cat("Loaded ", filename, ".")
    }else{
      
      #Load CDED file as a raster object, merge.
      r <- raster::merge(r, (raster::raster(file.path(temp2,filename))))
      cat("\nLoaded and merged ", filename, ".\n")
    }
    #Increment counter. 
    x <- x + 1
  }
  #Clean of temporary files.
  unlink(c(temp, temp2))
  
  #Project merged CDED raster to CRS of area of interest. 
  cat("\nReprojecting raster. ")
  r <- raster::projectRaster(r, crs = aoi_crs)
  
  #Crop raster to bounding box of area of interest.
  cat("\nCroping raster to aoi extent.\n")
  aoi_bbox <- sf::st_bbox(aoi)
  aoi_ext <- raster::extent(aoi_bbox[1], aoi_bbox[3], aoi_bbox[2], aoi_bbox[4])
  r <- raster::crop(r, aoi_ext)
  
  #If a resolution was provided, resample CDED to target resolution 
  if(!is.null(resolution))
  {
    targ_r<-raster::raster()
    raster::crs(targ_r)<-raster::crs(r)
    raster::extent(targ_r)<-raster::extent(r)
    raster::res(targ_r)<-resolution
    r<-raster::resample(r,targ_r,"bilinear")
    
  }
  
  #Inform user of duration 
  print(Sys.time() - start.time)
  
  #Return intersected CDED raster object 
  return(r)
  }else{
    #Inform user there was a issue with the CDED URL
    cat("The CDED URL cannot be reached.")
  }
}
