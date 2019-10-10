context("test-utils")

test_that("check_geom_col_names works", {
  skip("for a moment")
  col_df_list <- lapply(gml_types(), function(x) {
    data.frame(col_name = "SHAPE", remote_col_type = x)
  })
  lapply(col_df_list, function(x) {
    new_query <- specify_geom_name(x, "DWITHIN({geom_col}, foobar)")
    expect_equal(as.character(new_query), "DWITHIN(SHAPE, foobar)")
    expect_is(new_query, "sql")
  })
})

test_that("get_record_warn_once warns once and only once", {
  options("silence_named_get_record_warning" = FALSE)
  expect_warning(get_record_warn_once("Hi"))
  expect_silent(get_record_warn_once("Hi"))
  options("silence_named_get_record_warning" = TRUE)
})

test_that("pagination_sort_col works", {
  cols_df <- data.frame(
    col_name = c("foo", "OBJECTID", "OBJECT_ID", "SEQUENCE_ID", "FEATURE_ID"),
    stringsAsFactors = FALSE
  )
  expect_equal(pagination_sort_col(cols_df),
               "OBJECTID")
  expect_equal(pagination_sort_col(cols_df[-2, , drop = FALSE]),
               "OBJECT_ID")
  expect_equal(pagination_sort_col(cols_df[c(-2, -3), , drop = FALSE]),
               "SEQUENCE_ID")
  expect_warning(
    expect_equal(pagination_sort_col(cols_df[1, , drop = FALSE]),
               "foo")
  )
})

test_that("is_whse_object_name works", {
  expect_true(is_whse_object_name("BCGW_FOO.BAR_BAZ"))
  expect_false(is_whse_object_name("bcgw_foo.bar_baz"))
  expect_false(is_whse_object_name("foo"))
  expect_false(is_whse_object_name(structure(list(), class = "bcdc_record")))
})
