context("testing the output of bcdc_query_geodata")

test_that("bcdc_query_geodata returns an bcdc_promise object  for a valid id", {
  skip_if_net_down()
  bc_airports <- bcdc_query_geodata("bc-airports")
  expect_is(bc_airports, "bcdc_promise")
})

test_that("bcdc_query_geodata works with a bcdc_record", {
  skip_if_net_down()
  bc_airports_record <- bcdc_get_record("bc-airports")
  bc_airports <- bcdc_query_geodata(bc_airports_record)
  expect_is(bc_airports, "bcdc_promise")
})

test_that("bcdc_query_geodata returns an object with a query, a cli and the catalogue object",{
  skip_if_net_down()
  bc_airports <- bcdc_query_geodata("bc-airports")
  expect_equivalent(names(bc_airports), c("query_list", "cli", "obj"))
})


test_that("bcdc_query_geodata returns an object with bcdc_promise class when using filter",{
  bc_eml <- bcdc_query_geodata("bc-environmental-monitoring-locations") %>%
    filter(PERMIT_RELATIONSHIP == "DISCHARGE")
  expect_is(bc_eml, "bcdc_promise")
})


test_that("bcdc_query_geodata returns an object with bcdc_promise class on record under 10000",{
  skip_if_net_down()
  airports <- bcdc_query_geodata("bc-airports")
  expect_is(airports, "bcdc_promise")
})
