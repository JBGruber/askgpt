with_mock_dir("questions", {
  test_that("Ask questions", {
    expect_length(completions_api("is this a test?"), 7L)
    expect_length(chat_api("is this a test?"), 7L)
  })
})
