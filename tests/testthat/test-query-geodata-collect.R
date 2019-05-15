context("testing ability of bcdc_query_geodata to retrieve for bcdc using collect")

test_that("bcdc_query_geodata collects an sf object for a valid id", {
  skip_if_net_down()
  bc_airports <- bcdc_query_geodata("bc-airports") %>% collect()
  expect_is(bc_airports, "sf")
  expect_equal(attr(bc_airports, "sf_column"), "geometry")
})

test_that("bcdc_query_geodata succeeds with a records over 10000 rows",{
  skip("Skipping the BEC test, though available for testing")
  expect_silent(bcdc_query_geodata("terrestrial-protected-areas-representation-by-biogeoclimatic-unit"))
})


test_that("bcdc_query_geodata works with slug and full url using collect", {
  skip_if_net_down()
  expect_is(ret1 <- bcdc_query_geodata("https://catalogue.data.gov.bc.ca/dataset/bc-airports") %>% collect(),
            "sf")
  expect_is(ret2 <- bcdc_query_geodata("bc-airports") %>% collect(),
            "sf")
  expect_is(ret3 <- bcdc_query_geodata("https://catalogue.data.gov.bc.ca/dataset/76b1b7a3-2112-4444-857a-afccf7b20da8")
            %>% collect(),
            "sf")
  expect_is(ret4 <- bcdc_query_geodata("76b1b7a3-2112-4444-857a-afccf7b20da8") %>% collect(),
            "sf")
  ## Must be a better way to test if these objects are equal
  expect_true(all(unlist(lapply(list(ret1, ret2, ret3, ret4), nrow))))
  expect_true(all(unlist(lapply(list(ret1, ret2, ret3, ret4), ncol))))
})


test_that("bcdc_query_geodata works with spatial data that have SHAPE for the geom",{
  ## View metadata to see that geom is SHAPE
  ##bcdc_browse("fire-perimeters-historical")
  skip_if_net_down()
  crd <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()


  ret1 <- bcdc_query_geodata("fire-perimeters-historical") %>%
    filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
    collect()
  expect_is(ret1, "sf")
})

test_that("collect() returns a bcdc_sf object",{
  sf_obj <- bcdc_query_geodata("76b1b7a3-2112-4444-857a-afccf7b20da8") %>%
    filter(LOCALITY == "Terrace") %>%
    select(LATITUDE) %>%
    collect()
  expect_s3_class(sf_obj, "bcdc_sf")
})

test_that("bcdc_sf objects have a url as an attributes",{
  sf_obj <- bcdc_query_geodata("76b1b7a3-2112-4444-857a-afccf7b20da8") %>%
    filter(LOCALITY == "Terrace") %>%
    select(LATITUDE) %>%
    collect()

  res <- readLines(attributes(sf_obj)$url, warn = FALSE)
  expect_true(nzchar(res))
})



