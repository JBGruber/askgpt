#' Document R Code
#'
#' @param code A character vector of R code. If missing the code currently
#'   selected in RStudio is documented (If RStudio is used).
#' @param ... passed on to \code{\link{askgpt}}.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' \dontrun{
#' document_code()
#' }
document_code <- function(code, ...) {
  context <- NULL
  if (missing(code)) code <- get_selection()

  prompt <- glue::glue("Document this R function using roxygen2 syntax:",
                       "\n{code}")
  out <- askgpt(prompt, chat = FALSE, return_answer = TRUE, ...)

  if (rstudio_available()) {
    if (!is.null(context)) {
      rstudioapi::modifyRange(
        context$selection[[1L]]$range,
        paste0(out, collapse = "\n"),
        id = context$id
      )
      invisible(rstudioapi::documentSave(context$id))
    }
  }
  invisible(out)
}


#' Annotate R code with inline comments
#'
#' @inheritParams document_code
#' @return A character vector.
#' @export
annotate_code <- function(code, ...) {
  context <- NULL
  if (missing(code)) code <- get_selection()

  prompt <- glue::glue("Add inline comments to this R code:",
                       "\n{code}")
  out <- askgpt(prompt, chat = FALSE, return_answer = TRUE, ...)

  if (rstudio_available()) {
    if (!is.null(context)) {
      rstudioapi::modifyRange(
        context$selection[[1L]]$range,
        paste0(out, collapse = "\n"),
        id = context$id
      )
      invisible(rstudioapi::documentSave(context$id))
    }
  }
  invisible(out)
}


#' Explain R code
#'
#' @inheritParams document_code
#' @return A character vector.
#' @export
explain_code <- function(code, ...) {
  if (missing(code)) code <- get_selection()
  prompt <- glue::glue("Explain the following R code to me:",
                       "\n{code}")
  askgpt(prompt, chat = TRUE, ...)
}

#' Test R code
#'
#' @inheritParams document_code
#' @return A character vector.
#' @export
test_function <- function(code, ...) {
  if (missing(code)) code <- get_selection()
  prompt <- glue::glue("Write a testthat unit test for this R function:",
                       "\n{code}")
  askgpt(prompt, chat = TRUE, ...)
}

