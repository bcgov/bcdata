context("head and tail methods")

record <- "76b1b7a3-2112-4444-857a-afccf7b20da8"

test_that("head works", {
  promise <- bcdc_query_geodata(record) %>%
    head()
  expect_is(promise, "bcdc_promise")
  collected <- collect(promise)
  expect_equal(nrow(collected), 6L)
  d2 <- bcdc_query_geodata(record) %>%
                 head(n = 1) %>%
      collect()
  expect_equal(nrow(d2), 1L)
})
