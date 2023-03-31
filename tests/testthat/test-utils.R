test_that("rstudio_available", {
  expect_equal(class(rstudio_available()), "logical")
})
