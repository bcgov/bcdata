context("Testing ability to create CQL strings")
suppressPackageStartupMessages(library(sf, quietly = TRUE))

test_that("bcdc_cql_string fails when an invalid arguments are given",{
  airports <- bcdc_get_geodata("bc-airports")
  expect_error(bcdc_cql_string(airports, "FOO"))
  expect_error(bcdc_cql_string(quakes, "DWITHIN"))
})

test_that("CQL function works", {
  expect_is(CQL("SELECT * FROM foo;"), c("CQL", "SQL"))
})

the_geom <- st_sf(st_sfc(st_point(c(1,1))))

test_that("All cql geom predicate functions work", {
  single_arg_functions <- c("EQUALS","DISJOINT","INTERSECTS",
                            "TOUCHES", "CROSSES", "WITHIN",
                            "CONTAINS", "OVERLAPS")
  for (f in single_arg_functions) {
    expect_equal(
      do.call(f, list(the_geom)),
      CQL(paste0(f, "(GEOMETRY, POLYGON ((1 1, 1 1, 1 1, 1 1, 1 1)))"))
      )
  }
  expect_equal(
    DWITHIN(the_geom, 1), #default units meters
    CQL("DWITHIN(GEOMETRY, POLYGON ((1 1, 1 1, 1 1, 1 1, 1 1)), 1, 'meters')")
  )
  expect_equal(
    DWITHIN(the_geom, 1, "meters"),
    CQL("DWITHIN(GEOMETRY, POLYGON ((1 1, 1 1, 1 1, 1 1, 1 1)), 1, 'meters')")
  )
  expect_equal(
    BEYOND(the_geom, 1, "feet"),
    CQL("BEYOND(GEOMETRY, POLYGON ((1 1, 1 1, 1 1, 1 1, 1 1)), 1, 'feet')")
  )
  expect_equal(
    RELATE(the_geom, "*********"),
    CQL("RELATE(GEOMETRY, POLYGON ((1 1, 1 1, 1 1, 1 1, 1 1)), '*********')")
  )
  expect_equal(
    BBOX(c(1,2,1,2)),
    CQL("BBOX(GEOMETRY, 1, 2, 1, 2)")
  )
  expect_equal(
    BBOX(c(1,2,1,2), crs = 'EPSG:4326'),
    CQL("BBOX(GEOMETRY, 1, 2, 1, 2, 'EPSG:4326')")
  )
})

test_that("CQL functions fail correctly", {
  expect_error(EQUALS(quakes), "x is not a valid sf object")
  expect_error(BEYOND(the_geom, "five"), "'distance' must be numeric")
  expect_error(DWITHIN(the_geom, 5, "fathoms"), "'arg' should be one of")
  expect_error(RELATE(the_geom, "********"), "pattern") # 8 characters
  expect_error(RELATE(the_geom, "********5"), "pattern") # invalid character
  expect_error(RELATE(the_geom, rep("TTTTTTTTT", 2)), "pattern") # > length 1
})
