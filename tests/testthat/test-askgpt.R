test_that("Ask questions", {
  skip_on_cran()
  expect_length(httr2::with_mock(cache_response, completions_api("is this a test?")), 8L)
  expect_length(httr2::with_mock(cache_response, chat_api("is this a test?")), 8L)
  expect_snapshot(askgpt("", progress = FALSE, callfun = mockcall))
})

test_that("Error messages", {
  skip_on_cran()
  skip("Skipping since with_mock is not working right")
  expect_error(
    httr2::with_mock(mock_error, chat_api("is this a test?", api_key = "")),
    "This error can also mean that you ran out of credit."
  )
})
