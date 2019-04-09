for (nme in c("mean", "median", "max", "min")) {
  fun <- match.fun(nme)
  expect_false(is.numeric(fun(runif(10))), label = nme)
}




single_arg_functions <- c("EQUALS","DISJOINT","INTERSECTS",
                          "TOUCHES", "CROSSES", "WITHIN",
                          "CONTAINS", "OVERLAPS")

for(nme in single_arg_functions[6]){
  fun <- match.fun(nme)

  local <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()


  remote <- bcdc_query_geodata("bc-airports") %>%
    filter(fun(local)) %>%
    collect()

  expect_is(remote, "sf")
  expect_equal(attr(remote, "sf_column"), "geometry")
}
