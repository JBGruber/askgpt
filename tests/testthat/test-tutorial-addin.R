test_that("tutorialise utils", {
  expect_length(httr2::with_mock(cache_response, make_request("what does this do", "1 + 1")), 1L)
})
