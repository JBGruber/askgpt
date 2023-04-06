test_that("document", {
  skip_on_cran()
  expect_length(httr2::with_mock(cache_response, document_code("1 + 1", progress = FALSE)), 1L)
})

test_that("annotate", {
  skip_on_cran()
  expect_length(httr2::with_mock(cache_response, annotate_code("1 + 1", progress = FALSE)), 1L)
})

test_that("explain", {
  skip_on_cran()
  expect_length(httr2::with_mock(cache_response, explain_code("1 + 1", progress = FALSE)), 8L)
})

test_that("test", {
  skip_on_cran()
  expect_length(httr2::with_mock(cache_response, test_function("1 + 1", progress = FALSE)), 8L)
})
