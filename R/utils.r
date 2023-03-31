## import rlang to use operators
#' @import rlang

# package environment
the <- new.env(parent = emptyenv())

#' Initiate error logging
#'
#' @param ... forwarded to \code{\link[rlang]{global_entrace}}
#'
#' @details Just an alias for rlang::global_entrace() with a more fitting name (for the
#' purpose here).
#'
#' @return No return value, called to enable rlang error logging
#' @export
log_init <- function(...) {
  if (!isTRUE(the$log_init)) global_entrace(...)
  the$log_init <- TRUE
}


#' Return the prompt/response history
#'
#' @param n number of prompts/responses to return.
#'
#' @return a character vector
#' @export
prompt_history <- function(n = Inf) {
  return(utils::tail(the$prompts, n))
}


#' @inherit prompt_history
#' @return a character vector
#' @export
response_history <- function(n = Inf) {
  return(utils::tail(the$responses, n))
}

# safely check if rstudioapi is available
rstudio_available <- function() {
  out <- FALSE
  if (rlang::is_installed("rstudioapi")) out <- rstudioapi::isAvailable()
  return(out)
}

# get selected text from RStudio
get_selection <- function(variables) {
  if (rstudio_available()) {
    context <- rstudioapi::getActiveDocumentContext()
    code <- context$selection[[1L]]$text
  } else {
    cli::cli_abort("{.code code} is missing with no default")
  }
  return(code)
}

# log prompts and responses
log_ <- function(prompt, response, loc = Sys.getenv("askgpt_log_location")) {
  the$prompts <- c(the$prompts, prompt)
  the$responses <- c(the$responses, response)
  if (!is.null(loc)) {
    con <- file(loc, "ab")
    jsonlite::stream_out(data.frame(prompt = prompt, response = response),
                         con, verbose = FALSE)
    close(con)
  }
}
