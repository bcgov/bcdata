context("testing ability of filter methods to narrow a wfs query")
library(sf, quietly = TRUE)

test_that("bcdc_query_geodata accepts R expressions to refine data call",{
  skip_if_net_down()
  one_well <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    collect()
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("bcdc_query_geodata accepts R expressions to refine data call",{
  skip_if_net_down()
  one_well <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    collect()
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("operators work with different remote geom col names",{
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
  crd_fires <- bcdc_query_geodata("fire-perimeters-historical") %>%
    filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
    collect()
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
