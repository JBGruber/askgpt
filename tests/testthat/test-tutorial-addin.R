test_that("tutorialise utils", {
  skip_on_cran()
  expect_length(httr2::with_mock(cache_response, make_request("what does this do", "1 + 1")), 1L)
})

test_that("split prompt", {
  expect_length(split_prompt("This\nis\na\ntest", tok_max = 2), 4L)
})
