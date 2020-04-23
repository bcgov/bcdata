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
