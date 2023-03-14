test_that("Ask questions", {
  skip_on_cran()
  expect_length(httr2::with_mock(cache_response, completions_api("is this a test?")), 7L)
  expect_length(httr2::with_mock(cache_response, chat_api("is this a test?")), 7L)
  expect_length(httr2::with_mock(cache_response, askgpt("is this a test?", stream = TRUE)), 2L)
})
