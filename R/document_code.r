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
document_code <- function(code) {
  if (missing(code)) {
    rlang::check_installed("rstudioapi")
    context <- rstudioapi::getActiveDocumentContext()
    code <- context$selection[[1L]]$text
  }
  prompt <- glue::glue("Document this R function using roxygen2 syntax:",
                       "\n{code}")
  out <- askgpt(prompt, stream = FALSE, return_answer = TRUE)

  if (rlang::is_installed("rstudioapi")) {
    rstudioapi::modifyRange(
      context$selection[[1L]]$range,
      paste0(out, collapse = "\n"),
      id = context$id
    )
    invisible(rstudioapi::documentSave(context$id))
  }
  invisible(out)
}


#' Annotate R code with inline comments
#'
#' @inheritParams document_code
annotate_code <- function(code) {
  if (missing(code)) {
    rlang::check_installed("rstudioapi")
    context <- rstudioapi::getActiveDocumentContext()
    code <- context$selection[[1L]]$text
  }
  prompt <- glue::glue("Return this R code and add inline comments explaining it:",
                       "\n{code}")
  out <- askgpt(prompt, stream = FALSE, return_answer = TRUE)

  if (rlang::is_installed("rstudioapi")) {
    rstudioapi::modifyRange(
      context$selection[[1L]]$range,
      paste0(out, collapse = "\n"),
      id = context$id
    )
    invisible(rstudioapi::documentSave(context$id))
  }
  invisible(out)
}


#' Explain R code
#'
#' @inheritParams document_code
explain_code <- function(code) {
  if (missing(code)) {
    rlang::check_installed("rstudioapi")
    context <- rstudioapi::getActiveDocumentContext()
    code <- context$selection[[1L]]$text
  }
  prompt <- glue::glue("Explain the following R code to me:",
                       "\n{code}")
  askgpt(prompt, stream = FALSE)

}
