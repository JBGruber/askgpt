test_that("rstudio_available", {
  expect_equal(class(rstudio_available()), "logical")
})

test_that("history as file", {
  expect_s3_class({
    tmp <- tempfile()
    log_("test", "test2", tmp)
    jsonlite::stream_in(file(tmp), verbose = FALSE)
  }, "data.frame")
})

test_that("estimate number of tokens", {
  expect_equal(estimate_token("This is a test", mult = 1.6), 7L)
})
