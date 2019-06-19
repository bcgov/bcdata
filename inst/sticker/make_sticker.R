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
bc <- bc_bound_hres() %>%  ms_simplify(keep = 0.03)

city_lines_df <- cities %>%
  group_by(CITY_TYPE) %>%
  summarise(do_union = FALSE) %>%
  st_cast("LINESTRING")

p <- ggplot() +
  geom_sf(data = city_lines_df, aes(colour = CITY_TYPE), size = 0.2) +
  geom_sf(data = cities, size = .2) +
  geom_sf(data = bc, fill = NA, size = 0.15, colour = "black") +
  guides(colour = FALSE) +
  theme_void() +
  theme_transparent() +
  theme(panel.grid.major = element_line(colour = "white", size = 0.1)) +
  scale_colour_viridis_d()

sysfonts::font_add("Century Gothic", "/Library/Fonts/Microsoft/Century Gothic")

sticker(p, package = "bcdata",
        p_size = 5, # This seems to behave very differently on a Mac vs PC
        p_y = 1.6, p_color = "black", p_family = "Century Gothic",
        s_x = 1, s_y = .9,
        s_width = 1.5, s_height = 1.5,
        h_fill = "white", h_color = "black",
        filename = file.path("inst/sticker/bcdata.png"))

