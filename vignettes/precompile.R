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




# Precompile vignettes


library(knitr)
library(tools)
library(purrr)

# Convert *.orig to *.Rmd -------------------------------------------------

orig_files <- list.files(path = "vignettes/", pattern = "*\\.Rmd\\.orig", full.names = TRUE)

walk(orig_files, ~knit(.x, file_path_sans_ext(.x)))


# Move .png files into correct directory so they render -------------------

images <- list.files(".", pattern = 'vignette-fig.*\\.png$')

success <- file.copy(from = images,
                     to = file.path("vignettes", images),
                     overwrite = TRUE)


# Clean up if successful --------------------------------------------------

if (!all(success)) {
  stop("Image files were not successfully transferred to vignettes directory")
} else {
  unlink(images)
}
