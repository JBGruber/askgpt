#' Document R Code
#'
#' @param code A character vector of R code. If missing the code currently
#'   selected in RStudio is documented (If RStudio is used).
#' @return A character vector of R code with roxygen2 syntax.
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
  prompt <- glue::glue("Document this R Code using roxygen2 syntax:",
                       "\n{code}")
  out <- askgpt(prompt, return_answer = TRUE)

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
