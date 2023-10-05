
test_that("head works", {
  skip_if_net_down()
  skip_on_cran()
  promise <- bcdc_query_geodata(point_record) %>%
    head()
  expect_s3_class(promise, "bcdc_promise")
  collected <- collect(promise)
  expect_equal(nrow(collected), 6L)
  d2 <- bcdc_query_geodata(point_record) %>%
                 head(n = 3) %>%
      collect()
  expect_equal(nrow(d2), 3L)
  col <- pagination_sort_col(bcdc_describe_feature(point_record))
  full_airport <- bcdc_get_data(point_record, resource = point_resource)
  expect_equal(
    d2[[col]],
    head(full_airport[order(full_airport[[col]]),], 3L)[[col]]
  )
})

test_that("tail works", {
  skip_if_net_down()
  skip_on_cran()
  promise <- bcdc_query_geodata(point_record) %>%
    tail()
  expect_s3_class(promise, "bcdc_promise")
  collected <- collect(promise)
  expect_equal(nrow(collected), 6L)
  d2 <- bcdc_query_geodata(point_record) %>%
    tail(n = 3) %>%
    collect()
  expect_equal(nrow(d2), 3L)
  col <- pagination_sort_col(bcdc_describe_feature(point_record))
  full_airport <- bcdc_get_data(point_record, resource = point_resource)
  expect_equal(
    d2[[col]],
    tail(full_airport[order(full_airport[[col]]),], 3L)[[col]]
  )
})


test_that("head/tail works with a record that would otherwise require pagination",{
  skip_if_net_down()
  skip_on_cran()
  dh <- bcdc_query_geodata('2af1388e-d5f7-46dc-a6e2-f85415ddbd1c') %>%
    head(3) %>%
    collect()

  expect_equal(nrow(dh), 3L)

  dt <- bcdc_query_geodata('2af1388e-d5f7-46dc-a6e2-f85415ddbd1c') %>%
    tail(3) %>%
    collect()

  expect_equal(nrow(dt), 3L)
})

test_that("names.bcdc_promise returns the same as names on a data.frame", {
  skip_if_net_down()
  skip_on_cran()
  query01 <- bcdc_query_geodata(point_record) %>%
    head()

  expect_identical(
    names(query01),
    names(collect(query01))
  )
})

test_that("names.bcdc_promise returns the same as names on a data.frame when using select", {
  skip_if_net_down()
  skip_on_cran()
  query02 <- bcdc_query_geodata(polygon_record) %>%
    head() %>%
    select(1:3)

  expect_identical(
    names(query02),
    names(collect(query02))
  )
})
