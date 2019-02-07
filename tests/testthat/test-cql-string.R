context("Testing ability to create CQL strings")

test_that("bcdc_cql_string fails when an invalid arguments are given",{
  airports <- bcdc_get_geodata("bc-airports")
  expect_error(bcdc_cql_string(airports, "FOO"))
  expect_error(bcdc_cql_string(quakes, "DWITHIN"))
})
