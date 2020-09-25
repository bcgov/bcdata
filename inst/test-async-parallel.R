library(crul)
library(sf)
library(glue)
library(future)
library(future.apply)

start_and_chunks <- function(n_records, limit) {
  last <- n_records %% limit

  start_indexes <- seq(0, n_records, by = limit)
  # Remove the last start index if same as number of records
  start_indexes <- setdiff(start_indexes, n_records)
  chunk_sizes <- rep(limit, length(start_indexes))

  if (last) {
    chunk_sizes[length(chunk_sizes)] <- last
  }

  stopifnot(length(chunk_sizes) == length(start_indexes))

  list(start_indexes = start_indexes,
       chunk_sizes = chunk_sizes)
}

combine_list <- function(res) {
  json_list <- lapply(res, function(x) x$parse("UTF-8"))

  sf_list <- lapply(json_list, sf::st_read, quiet = TRUE, stringsAsFactors = FALSE)

  sf_obj <- do.call("rbind", sf_list)

  nrow(sf_obj) == number_of_records
  length(unique(sf_obj$OBJECTID)) == number_of_records

  sf_obj
}

query_list <- function() {
  list(
    SERVICE = "WFS",
    VERSION = "2.0.0",
    REQUEST = "GetFeature",
    outputFormat = "application/json",
    typeNames = "WHSE_FOREST_VEGETATION.BEC_BIOGEOCLIMATIC_POLY",
    sortby = "OBJECTID"
  )
}

get_bec_paging <- function(n, limit_chunk) {

  url_base <- "https://openmaps.gov.bc.ca/geo/pub/wfs"

  cli <- crul::HttpClient$new(url = url_base)

  cc <- crul::Paginator$new(
    client = cli,
    by = "query_params",
    limit_param = "count",
    offset_param = "startIndex",
    limit = number_of_records,
    limit_chunk = limit_chunk
  )

  res <- cc$post(body = query_list(), encode = "form")

  combine_list(res)
}

get_bec_async <- function(n, limit_chunk) {

  i_c <- start_and_chunks(n, limit_chunk)

  url_base <- glue("https://openmaps.gov.bc.ca/geo/pub/wfs?startIndex={i_c$start_indexes}&count={i_c$chunk_sizes}")

  cc <- Async$new(urls = url_base)

  res <- cc$post(body = query_list(), encode = "form")

  combine_list(res)
}

get_bec_parallel <- function(n, limit_chunk) {

  i_c <- start_and_chunks(n, limit_chunk)

  url_base <- glue("https://openmaps.gov.bc.ca/geo/pub/wfs?startIndex={i_c$start_indexes}&count={i_c$chunk_sizes}")

  res <- future_lapply(url_base, function(u) {

    cli <- crul::HttpClient$new(url = u)
    r <- cli$post(body = query_list(), encode = "form")
    json <- r$parse("UTF-8")
    sf::st_read(json, quiet = TRUE, stringsAsFactors = FALSE)

  },
  future.seed = NULL
  )

  do.call("rbind", res)

}

#########################################################

number_of_records <- 15267
limit_chunk <- 1000

# number_of_records <- 200
# limit_chunk <- 30

future::plan(multiprocess(workers = 4))


cat("Paging\n")
tictoc::tic()
b1 <- get_bec_paging(n = number_of_records, limit_chunk = limit_chunk)
tictoc::toc()

Sys.sleep(60)

cat("Async\n")
tictoc::tic()
b2 <- get_bec_async(n = number_of_records, limit_chunk = limit_chunk)
tictoc::toc()

Sys.sleep(60)

cat("Parallel\n")
tictoc::tic()
b3 <- get_bec_parallel(n = number_of_records, limit_chunk = limit_chunk)
tictoc::toc()

all.equal(b1, b2)
all.equal(b2, b3)

