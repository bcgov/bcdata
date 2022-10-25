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
  one_feature <- bcdc_query_geodata(point_record) %>%
    filter(SOURCE_DATA_ID == '455') %>%
    collect()
  expect_is(one_feature, "sf")
  expect_equal(attr(one_feature, "sf_column"), "geometry")
  expect_equal(nrow(one_feature), 1)
})

test_that("bcdc_query_geodata accepts R expressions to refine data call",{
  skip_on_cran()
  skip_if_net_down()
  one_feature <- bcdc_query_geodata(point_record) %>%
    filter(SOURCE_DATA_ID == '455') %>%
    collect()
  expect_is(one_feature, "sf")
  expect_equal(attr(one_feature, "sf_column"), "geometry")
  expect_equal(nrow(one_feature), 1)
})

test_that("operators work with different remote geom col names",{
  skip_on_cran()
  skip_if_net_down()

  ## LOCAL
  crd <- bcdc_query_geodata(polygon_record) %>%
    filter(ADMIN_AREA_NAME == "Capital Regional District") %>%
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
  the_bbox <- st_sfc(st_polygon(
    list(structure(c(1670288.515, 1719022.009,
                     1719022.009, 1670288.515, 1670288.515, 667643.77, 667643.77,
                     745981.738, 745981.738, 667643.77), .Dim = c(5L, 2L)))),
    crs = 3005)

  # with raw CQL
  expect_equal(as.character(cql_translate(CQL('"POP_2000" < 2000'),
                                          .colnames = "POP_2000")),
               "(\"POP_2000\" < 2000)")

  # just with spatial predicate
  expect_equal(as.character(cql_translate(WITHIN(the_bbox))),
               "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))))")

  # spatial predicate combined with regular comparison using comma
  and_statement <- "((WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8)))) AND (\"POP_2000\" < 2000))"
  expect_equal(as.character(cql_translate(WITHIN(the_bbox), POP_2000 < 2000L,
                            .colnames = "POP_2000")),
               and_statement)

  # spatial predicate combined with regular comparison as a named object using comma
  pop <- 2000L
  expect_equal(as.character(cql_translate(WITHIN(the_bbox), POP_2000 < pop,
                                          .colnames = "POP_2000")),
               and_statement)

  and_with_logical <- "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))) AND \"POP_2000\" < 2000)"
  # spatial predicate combined with regular comparison as a named object using
  # explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) & POP_2000 < pop,
                                          .colnames = "POP_2000")),
               and_with_logical)

  # spatial predicate combined with regular comparison as a named object using
  # explicit |
  or_statement <- "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))) OR \"POP_2000\" < 2000)"
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) | POP_2000 < pop,
                                          .colnames = "POP_2000")),
               or_statement)

  # spatial predicate combined with CQL using comma
  expect_equal(as.character(cql_translate(WITHIN(the_bbox),
                                          CQL("\"POP_2000\" < 2000"),
                                          .colnames = "POP_2000")),
               and_statement)

  # spatial predicate combined with CQL using explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) &
                                            CQL("\"POP_2000\" < 2000"),
                                          .colnames = "POP_2000")),
               and_with_logical)

  # spatial predicate combined with CQL using explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) |
                                            CQL("\"POP_2000\" < 2000"),
                                          .colnames = "POP_2000")),
               or_statement)
})

test_that("subsetting works locally", {
  x <- c("a", "b")
  y <- data.frame(id = x, stringsAsFactors = FALSE)
  expect_equal(as.character(cql_translate(foo == x[1], .colnames = "foo")),
               "(\"foo\" = 'a')")
  expect_equal(as.character(cql_translate(foo %in% local(y$id), .colnames = "foo")),
               "(\"foo\" IN ('a', 'b'))")
  expect_equal(as.character(cql_translate(foo %in% y[["id"]], .colnames = "foo")),
               "(\"foo\" IN ('a', 'b'))")
  expect_equal(as.character(cql_translate(foo == local(y$id[2]), .colnames = "foo")),
               "(\"foo\" = 'b')")
})

test_that("large vectors supplied to filter succeeds",{
  skip_on_cran()
  skip_if_net_down()
  pori <- bcdc_query_geodata(lines_record) %>%
    filter(WATERSHED_GROUP_CODE %in% "PORI") %>%
    collect()

  expect_is(bcdc_query_geodata(lines_record) %>%
    filter(WATERSHED_KEY %in% pori$WATERSHED_KEY),
    "bcdc_promise")

})

test_that("multiple filter statements are additive",{
  skip_on_cran()
  skip_if_net_down()
  airports <- bcdc_query_geodata(point_record)

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
  crd <- bcdc_query_geodata(polygon_record) %>%
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

  regions <- bcdc_query_geodata(polygon_record) %>%
    filter(ADMIN_AREA_NAME %in% c("Bulkley Nechako Regional District", "Cariboo Regional District", "Regional District of Fraser-Fort George")) %>%
    collect()

  expect_true(utils::object.size(regions) > 5E5)

  expect_message(parks <- bcdc_query_geodata(record = "6a2fea1b-0cc4-4fc2-8017-eaf755d516da") %>%
    filter(WITHIN(regions)) %>%
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


  expect_is(parks <- bcdc_query_geodata(record = "6a2fea1b-0cc4-4fc2-8017-eaf755d516da") %>%
    filter(WITHIN(small_districts)) %>%
    collect(),
    "bcdc_sf")
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
    filter(BBOX(local(st_bbox(the_geom, crs = st_crs(the_geom))))) %>%
    show_query()

  expect_equal(as.character(qry$query_list$CQL_FILTER),
               "(BBOX(SHAPE, 1164434, 368738, 1203023, 412959, 'EPSG:3005'))")

  qry2 <- bcdc_query_geodata("local-and-regional-greenspaces") %>%
    filter(DWITHIN(local(st_buffer(the_geom, 10000, nQuadSegs = 2)), 100, "meters")) %>%
    show_query()

    expect_match(as.character(qry2$query_list$CQL_FILTER),
               "\\(DWITHIN\\(SHAPE, MULTIPOLYGON \\(\\(\\([0-9. ,()]+\\)\\)\\), 100, meters\\)\\)")

  # Informative error when omit local:
  expect_error(bcdc_query_geodata("local-and-regional-greenspaces") %>%
                 filter(DWITHIN(st_buffer(the_geom, 10000, nQuadSegs = 2), 100, "meters")),
               "Unable to process query")
})

test_that("works with dates", {
  skip_if_net_down()
  skip_on_cran()
  expect_is(bcdc_query_geodata('historical-orders-and-alerts') %>%
              filter(EVENT_START_DATE < "2017-05-01") %>%
              collect(), "bcdc_sf")
  expect_is(bcdc_query_geodata('historical-orders-and-alerts') %>%
              filter(EVENT_START_DATE < as.Date("2017-05-01")) %>%
              collect(), "bcdc_sf")
  expect_is(bcdc_query_geodata('historical-orders-and-alerts') %>%
              filter(EVENT_START_DATE < as.POSIXct("2017-05-01")) %>%
              collect(), "bcdc_sf")
  dt <- as.Date("2017-05-01")
  expect_is(bcdc_query_geodata('historical-orders-and-alerts') %>%
              filter(EVENT_START_DATE < dt) %>%
              collect(), "bcdc_sf")
  pt <- as.Date("2017-05-01")
  expect_is(bcdc_query_geodata('historical-orders-and-alerts') %>%
              filter(EVENT_START_DATE < pt) %>%
              collect(), "bcdc_sf")
})

test_that("works with various as.x functions", {
  skip_if_net_down()
  skip_on_cran()
  expect_is(
    bcdc_query_geodata(point_record) %>%
      filter(NUMBER_OF_RUNWAYS == as.numeric("3")) %>%
      collect(),
    "bcdc_sf")
  expect_is(
    bcdc_query_geodata(point_record) %>%
      filter(DESCRIPTION == as.character("seaplane anchorage")) %>%
      collect(),
    "bcdc_sf")
})
