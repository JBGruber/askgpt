#' Document R Code
#'
#' @param code A character vector of R code. If missing the code currently
#'   selected in RStudio is documented (If RStudio is used).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' document_code()
#' }
document_code <- function(code, ...) {
  context <- NULL
  if (missing(code)) {
    if (rstudio_available()) {
      context <- rstudioapi::getActiveDocumentContext()
      code <- context$selection[[1L]]$text
    } else (
      cli::cli_abort("{.code code} is missing with no default")
    )
  }
  prompt <- glue::glue("Document this R function using roxygen2 syntax:",
                       "\n{code}")
  out <- askgpt(prompt, chat = FALSE, stream = FALSE, return_answer = TRUE, ...)

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
#' @export
annotate_code <- function(code, ...) {
  context <- NULL
  if (missing(code)) {
    if (rstudio_available()) {
      context <- rstudioapi::getActiveDocumentContext()
      code <- context$selection[[1L]]$text
    } else (
      cli::cli_abort("{.code code} is missing with no default")
    )
  }

  prompt <- glue::glue("Return this R code and add inline comments explaining it:",
                       "\n{code}")
  out <- askgpt(prompt, chat = FALSE, stream = FALSE, return_answer = TRUE, ...)

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
#' @export
explain_code <- function(code, ...) {
  if (missing(code)) {
    if (rstudio_available()) {
      rlang::check_installed("rstudioapi")
      context <- rstudioapi::getActiveDocumentContext()
      code <- context$selection[[1L]]$text
    } else (
      cli::cli_abort("{.code code} is missing with no default")
    )
  }
  prompt <- glue::glue("Explain the following R code to me:",
                       "\n{code}")
  askgpt(prompt, chat = TRUE, stream = FALSE, ...)
}
