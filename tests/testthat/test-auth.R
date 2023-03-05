test_that("retrieve key", {
  expect_no_match(login(no_cache = TRUE), "^$")
})

test_that("key cache", {
  temp_cache <- tempdir()
  expect_length(
    {
      login(cache_dir = temp_cache, no_cache = TRUE)
      list.files(temp_cache)
    },
    0L
  )
  expect_length(
    {
      login(cache_dir = temp_cache)
      list.files(temp_cache)
    },
    1L
  )
})
