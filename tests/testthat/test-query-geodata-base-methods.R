context("head and tail methods")
library(dplyr)

record <- "76b1b7a3-2112-4444-857a-afccf7b20da8"
resource <- "4d0377d9-e8a1-429b-824f-0ce8f363512c"

test_that("head works", {
  skip_if_net_down()
  skip_on_cran()
  promise <- bcdc_query_geodata(record) %>%
    head()
  expect_is(promise, "bcdc_promise")
  collected <- collect(promise)
  expect_equal(nrow(collected), 6L)
  d2 <- bcdc_query_geodata(record) %>%
                 head(n = 3) %>%
      collect()
  expect_equal(nrow(d2), 3L)
  col <- pagination_sort_col(bcdc_describe_feature(record))
  expect_equal(
    d2[[col]],
    head(arrange(bcdc_get_data(record, resource = resource), .data[[col]]), 3L)[[col]]
  )
})

test_that("tail works", {
  skip_if_net_down()
  skip_on_cran()
  promise <- bcdc_query_geodata(record) %>%
    tail()
  expect_is(promise, "bcdc_promise")
  collected <- collect(promise)
  expect_equal(nrow(collected), 6L)
  d2 <- bcdc_query_geodata(record) %>%
    tail(n = 3) %>%
    collect()
  expect_equal(nrow(d2), 3L)
  col <- pagination_sort_col(bcdc_describe_feature(record))
  expect_equal(
    d2[[col]],
    tail(arrange(bcdc_get_data(record, resource = resource), .data[[col]]), 3L)[[col]]
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
  query <- bcdc_query_geodata(point_record) %>%
    head()

  expect_identical(
    names(query),
    names(collect(query))
  )
})

test_that("names.bcdc_promise returns the same as names on a data.frame when using select", {
  sub_query <- bcdc_query_geodata(polygon_record) %>%
    head() %>%
    select(1:3)

  expect_identical(
    names(sub_query),
    names(collect(sub_query))
  )
})
