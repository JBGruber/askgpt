test_that("retrieve key", {
  skip_on_cran()
  expect_no_match(login(no_cache = TRUE), "^$")
})

test_that("key cache", {
  skip_on_cran()
  temp_cache <- tempdir()
  expect_length(
    {
      login(cache_dir = temp_cache, no_cache = TRUE)
      list.files(temp_cache)
    },
    0L
  )
  expect_error(withr::with_envvar(new = c("OPENAI_API_KEY" = ""),
                                  login(cache_dir = temp_cache)),
               "No API key available")
  expect_length(
    {
      login(cache_dir = temp_cache)
      list.files(temp_cache)
    },
    1L
  )
})
