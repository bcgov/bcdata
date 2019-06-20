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

library(hexSticker)
library(ggplot2)
library(bcmaps)
library(sf)
library(dplyr)
library(rmapshaper)

cities <- bc_cities()
bc <- bc_bound() %>% ms_simplify(keep = .1)

city_lines_df <- cities %>%
  st_union() %>%
  st_triangulate(bOnlyEdges = TRUE) %>%
  st_cast("LINESTRING") %>%
  st_sf() %>%
  mutate(length = as.numeric(st_length(.))) %>%
  filter(length < 500000)

p <- ggplot() +
  geom_sf(data = bc, fill = NA, size = 0.2, colour = "grey70") +
  geom_sf(data = city_lines_df, aes(colour = length), size = 0.2) +
  scale_colour_viridis_c(direction = -1, option = "plasma", begin = .3) +
  geom_sf(data = cities, colour = "white", size = 0.01, shape = 20) +
  guides(colour = FALSE) +
  theme_void() +
  theme_transparent() +
  coord_sf(datum = NULL)

font_path <- switch (Sys.info()['sysname'],
                     Darwin = "/Library/Fonts/Microsoft/Century Gothic",
                     Windows = "C:/WINDOWS/FONTS/GOTHIC.TTF"
)

sysfonts::font_add("Century Gothic", font_path)

sticker(p, package = "bcdata",
        p_size = 5, # This seems to behave very differently on a Mac vs PC
        p_y = 1.6, p_color = "grey70", p_family = "Century Gothic",
        s_x = 1, s_y = .9,
        s_width = 1.5, s_height = 1.5,
        h_fill = "#29303a", h_color = "grey70",
        filename = file.path("inst/sticker/bcdata.svg"))

# Run:
# userthis::use_logo("inst/sticker/bcdata.svg")

