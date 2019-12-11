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

context("testing ability of filter methods to narrow a wfs query")
library(sf, quietly = TRUE)

test_that("bcdc_query_geodata accepts R expressions to refine data call",{
  skip_on_cran()
  skip_if_net_down()
  one_well <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    collect()
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("bcdc_query_geodata accepts R expressions to refine data call",{
  skip_on_cran()
  skip_if_net_down()
  one_well <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    collect()
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("operators work with different remote geom col names",{
  skip_on_cran()
  skip_if_net_down()

  ## LOCAL
  crd <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()

  ## REMOTE "GEOMETRY"
  em_program <- bcdc_query_geodata("employment-program-of-british-columbia-regional-boundaries") %>%
    filter(INTERSECTS(crd)) %>%
    collect()
  expect_is(em_program, "sf")
  expect_equal(attr(em_program, "sf_column"), "geometry")

  ## REMOTE "SHAPE"
  crd_fires <- suppressWarnings(
    bcdc_query_geodata("fire-perimeters-historical") %>%
      filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
      collect()
  )
  expect_is(crd_fires, "sf")
  expect_equal(attr(crd_fires, "sf_column"), "geometry")

})

test_that("Different combinations of predicates work", {
  skip_on_cran()
  the_bbox <- st_sfc(st_polygon(
    list(structure(c(1670288.515, 1719022.009,
                     1719022.009, 1670288.515, 1670288.515, 667643.77, 667643.77,
                     745981.738, 745981.738, 667643.77), .Dim = c(5L, 2L)))),
    crs = 3005)

  # with raw CQL
  expect_equal(as.character(cql_translate(CQL('"POP_2000" < 2000'))),
               "(\"POP_2000\" < 2000)")

  # just with spatial predicate
  expect_equal(as.character(cql_translate(WITHIN(the_bbox))),
               "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))))")

  # spatial predicate combined with regular comparison using comma
  and_statement <- "((WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8)))) AND (\"POP_2000\" < 2000))"
  expect_equal(as.character(cql_translate(WITHIN(the_bbox), POP_2000 < 2000L)),
               and_statement)

  # spatial predicate combined with regular comparison as a named object using comma
  pop <- 2000L
  expect_equal(as.character(cql_translate(WITHIN(the_bbox), POP_2000 < pop)),
               and_statement)

  and_with_logical <- "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))) AND \"POP_2000\" < 2000)"
  # spatial predicate combined with regular comparison as a named object using
  # explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) & POP_2000 < pop)),
               and_with_logical)

  # spatial predicate combined with regular comparison as a named object using
  # explicit |
  or_statement <- "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))) OR \"POP_2000\" < 2000)"
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) | POP_2000 < pop)),
               or_statement)

  # spatial predicate combined with CQL using comma
  expect_equal(as.character(cql_translate(WITHIN(the_bbox),
                                          CQL("\"POP_2000\" < 2000"))),
               and_statement)

  # spatial predicate combined with CQL using explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) &
                                            CQL("\"POP_2000\" < 2000"))),
               and_with_logical)

  # spatial predicate combined with CQL using explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) |
                                            CQL("\"POP_2000\" < 2000"))),
               or_statement)
})

test_that("subsetting works locally", {
  x <- c("a", "b")
  y <- data.frame(id = x, stringsAsFactors = FALSE)
  expect_equal(as.character(cql_translate(foo == x[1])),
               "(\"foo\" = 'a')")
  expect_equal(as.character(cql_translate(foo %in% y$id)),
               "(\"foo\" IN ('a', 'b'))")
  expect_equal(as.character(cql_translate(foo %in% y[["id"]])),
               "(\"foo\" IN ('a', 'b'))")
  expect_equal(as.character(cql_translate(foo == y$id[2])),
               "(\"foo\" = 'b')")
})

test_that("large vectors supplied to filter succeeds",{
  skip_on_cran()
  skip_if_net_down()
  pori <- bcdc_query_geodata("freshwater-atlas-stream-network") %>%
    filter(WATERSHED_GROUP_CODE %in% "PORI") %>%
    collect()

  expect_silent(bcdc_query_geodata("freshwater-atlas-stream-network") %>%
    filter(WATERSHED_KEY %in% pori$WATERSHED_KEY))

})

test_that("multiple filter statements are additive",{
  skip_on_cran()
  skip_if_net_down()
  airports <- bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8')

  heliports_in_victoria <-  airports %>%
    filter(PHYSICAL_ADDRESS == "Victoria, BC") %>%
    filter(DESCRIPTION == "heliport") %>%
    collect()

  ## this is additive only Victoria, BC should be a physical address
  expect_true(unique(heliports_in_victoria$PHYSICAL_ADDRESS) == "Victoria, BC")

  heliports_one_line <- airports %>%
    filter(PHYSICAL_ADDRESS == "Victoria, BC", DESCRIPTION == "heliport")
  heliports_two_line <- airports %>%
    filter(PHYSICAL_ADDRESS == "Victoria, BC") %>%
    filter(DESCRIPTION == "heliport")

  expect_identical(finalize_cql(heliports_one_line$query_list$CQL_FILTER),
                   finalize_cql(heliports_two_line$query_list$CQL_FILTER))
})

test_that("multiple filter statements are additive with geometric operators",{
  skip_on_cran()
  skip_if_net_down()
  ## LOCAL
  crd <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect() %>%
    st_bbox() %>%
    st_as_sfc()

  ## REMOTE "GEOMETRY"
  em_program <- bcdc_query_geodata("employment-program-of-british-columbia-regional-boundaries") %>%
    filter(ELMSD_REGION_BOUNDARY_NAME == "Interior") %>%
    filter(INTERSECTS(crd))

  cql_query <- "((\"ELMSD_REGION_BOUNDARY_NAME\" = 'Interior') AND (INTERSECTS(GEOMETRY, POLYGON ((956376 653960.8, 1397042 653960.8, 1397042 949343.3, 956376 949343.3, 956376 653960.8)))))"

  expect_equal(as.character(finalize_cql(em_program$query_list$CQL_FILTER)),
               cql_query)
})


test_that("an intersect with an object greater than 5E5 bytes automatically gets turned into a bbox",{
  skip_on_cran()
  skip_if_net_down()
  districts <- bcdc_query_geodata("78ec5279-4534-49a1-97e8-9d315936f08b") %>%
    filter(SCHOOL_DISTRICT_NAME %in% c("Greater Victoria", "Prince George","Kamloops/Thompson")) %>%
    collect()

  expect_true(utils::object.size(districts) > 5E5)

  expect_warning(parks <- bcdc_query_geodata(record = "6a2fea1b-0cc4-4fc2-8017-eaf755d516da") %>%
    filter(WITHIN(districts)) %>%
      collect())
})


test_that("an intersect with an object less than 5E5 proceeds",{
  skip_on_cran()
  skip_if_net_down()
  small_districts <- bcdc_query_geodata("78ec5279-4534-49a1-97e8-9d315936f08b") %>%
    filter(SCHOOL_DISTRICT_NAME %in% c("Prince George")) %>%
    collect() %>%
    st_bbox() %>%
    st_as_sfc()


  expect_silent(parks <- bcdc_query_geodata(record = "6a2fea1b-0cc4-4fc2-8017-eaf755d516da") %>%
    filter(WITHIN(small_districts)) %>%
    collect())
})

test_that("a BCGW name works with filter", {
  skip_on_cran()
  skip_if_net_down()
  little_box <- st_as_sfc(st_bbox(c(xmin = 506543.662, ymin = 467957.582,
                                    xmax = 1696644.998, ymax = 1589145.873),
                                  crs = 3005))

  expect_silent(ret <- bcdc_query_geodata("WHSE_IMAGERY_AND_BASE_MAPS.GSR_AIRPORTS_SVW") %>%
    filter(WITHIN(little_box)) %>%
    collect())
  expect_equal(nrow(ret), 367)
})

test_that("Using BBOX works", {
  skip_on_cran()
  skip_if_net_down()
  query <- bcdc_query_geodata("WHSE_FOREST_VEGETATION.BEC_BIOGEOCLIMATIC_POLY", crs = 4326) %>%
    filter(BBOX(c(1639473.0,528785.2,1665979.9,541201.0), crs = "EPSG:3005")) %>%
    show_query()
  expect_equal(query$query_list$CQL_FILTER,
               structure("(BBOX(GEOMETRY, 1639473, 528785.2, 1665979.9, 541201, 'EPSG:3005'))",
                         class = c("sql", "character")))
})

test_that("Nesting functions inside a CQL geometry predicate works (#146)", {
  skip_on_cran()
  skip_if_net_down()
  the_geom <- st_sfc(st_point(c(1164434, 368738)),
                     st_point(c(1203023, 412959)),
                     crs = 3005)

  qry <- bcdc_query_geodata("local-and-regional-greenspaces") %>%
    filter(BBOX(st_bbox(the_geom), crs = paste0("EPSG:", st_crs(the_geom)$epsg))) %>%
    show_query()

  expect_equal(as.character(qry$query_list$CQL_FILTER),
               "(BBOX(SHAPE, 1164434, 368738, 1203023, 412959, 'EPSG:3005'))")

  qry2 <- bcdc_query_geodata("local-and-regional-greenspaces") %>%
    filter(DWITHIN(st_buffer(the_geom, 10, nQuadSegs = 2), 100, "meters")) %>%
    show_query()

  expect_equal(as.character(qry2$query_list$CQL_FILTER),
               "(DWITHIN(SHAPE, MULTIPOLYGON (((1164444 368738, 1164441 368730.9, 1164434 368728, 1164427 368730.9, 1164424 368738, 1164427 368745.1, 1164434 368748, 1164441 368745.1, 1164444 368738)), ((1203033 412959, 1203030 412951.9, 1203023 412949, 1203016 412951.9, 1203013 412959, 1203016 412966.1, 1203023 412969, 1203030 412966.1, 1203033 412959))), 100, meters))")
})
