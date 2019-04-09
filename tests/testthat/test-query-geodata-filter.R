context("testing ability of filter methods to narrow a wfs query")

test_that("bcdc_get_geodata accepts R expressions to refine data call",{
  skip_if_net_down()
  one_well <- bcdc_get_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    collect()
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("bcdc_get_geodata accepts R expressions to refine data call",{
  skip_if_net_down()
  one_well <- bcdc_get_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    collect()
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("operators work with different remote geom col names",{
  skip_if_net_down()

  ## LOCAL
  crd <- bcdc_get_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()

  ## REMOTE "GEOMETRY"
  em_program <- bcdc_get_geodata("employment-program-of-british-columbia-regional-boundaries") %>%
    filter(INTERSECTS(crd)) %>%
    collect()
  expect_is(em_program, "sf")
  expect_equal(attr(em_program, "sf_column"), "geometry")

  ## REMOTE "SHAPE"
  crd_fires <- bcdc_get_geodata("fire-perimeters-historical") %>%
    filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
    collect()
  expect_is(crd_fires, "sf")
  expect_equal(attr(crd_fires, "sf_column"), "geometry")

})
