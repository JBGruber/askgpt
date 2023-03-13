test_that("document", {
  expect_length(httr2::with_mock(cache_response, document_code("1 + 1", progress = FALSE)), 1L)
})

test_that("annotate", {
  expect_length(httr2::with_mock(cache_response, annotate_code("1 + 1", progress = FALSE)), 1L)
})

test_that("explain", {
  expect_length(httr2::with_mock(cache_response, explain_code("1 + 1", progress = FALSE)), 7L)
})

