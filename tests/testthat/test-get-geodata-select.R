context("testing ability of select methods to narrow a wfs query")

test_that("select doesn't remove the geometry column",{
  skip_if_net_down()

  gw_wells <- bcdc_get_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    select(SOURCE_ACCURACY) %>%
    collect()
  expect_false(st_is_empty(gw_wells$geometry))
})

test_that("select works when selecting a column that isn't sticky",{
  skip_if_net_down()
  one_well <- bcdc_get_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    select(FCODE) %>%
    collect()

  expect_true("FCODE" %in% names(one_well))
})


test_that("select reduces the number of columns when a sticky ",{
  skip_if_net_down()

  feature_spec <- bcdc_describe_feature("ground-water-wells")
  ## Columns that can selected, while manually including GEOMETRY col
  sticky_cols <- c(
    feature_spec[feature_spec$nillable != TRUE,]$col_name,
    "geometry")

  sub_cols <- bcdc_get_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    select(WELL_ID) %>%
    collect()
  ## id col added by wfs
  sub_cols$id <- NULL

  expect_identical(names(sub_cols), sticky_cols)



})
