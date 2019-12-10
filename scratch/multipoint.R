
format_multipoint <- function(x) {
  x <- gsub("(\\(\\d+(\\.)?\\d*)", "(\\1", x)
  x <- gsub("(\\d+),\\s*", "\\1), (", x)
  gsub("(\\))$", "\\1)", x)
}

format_wkt("MULTIPOINT (1164434 368738.7, 1203024 412959)")
format_wkt("POINT (1164434 368738.7)")
format_wkt("MULTIPOINT (1164434 368738.7, 1203024 412959, 1203025 412960)")
format_wkt("MULTIPOINT (1164434 368738.7 20, 1203024 412959 50, 1203025 412960 100)")

st_as_text(st_as_sfc("MULTIPOINT ((10 10), (20 20))"))
