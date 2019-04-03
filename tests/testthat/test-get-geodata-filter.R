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
