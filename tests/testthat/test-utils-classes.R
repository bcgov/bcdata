test_that("Paginator instantiation did not change fields name", {

  # Used fields in collect.bcdc_promise
  expect_true(
    all(
      c("by", "limit_param", "offset_param", "limit",
        "chunk", "progress") %in% names(crul::Paginator$public_fields)
    )
  )

})
