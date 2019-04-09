context("Geometric operators work with appropriate data")

test_that("WITHIN works",{
  local <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()

  remote <- bcdc_query_geodata("bc-airports") %>%
    filter(WITHIN(local)) %>%
    collect()

  expect_is(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")

})


test_that("INTERSECT works",{
  local <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()

  remote <- bcdc_query_geodata("bc-parks-ecological-reserves-and-protected-areas") %>%
    filter(FEATURE_LENGTH_M <= 1000, INTERSECTS(local)) %>%
    collect()

  expect_is(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")

})


