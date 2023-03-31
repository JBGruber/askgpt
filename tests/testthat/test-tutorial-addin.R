test_that("prompt_template returns the expected message", {
  code <- "print('Hello, World!')"
  target <- "beginners"
  goal <- "how to write a basic R program with a print statement"
  expected_output <- "Turn this into a tutorial for beginners and explain how to write a basic R program with a print statement, return it as an R Markdown document:\nprint('Hello, World!')"
  actual_output <- prompt_template(code, target, goal)

  expect_equal(actual_output, expected_output)
})
