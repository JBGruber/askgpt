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

#' Start a new conversation
#'
#' Deletes the local prompt and response history to start a new conversation.
#'
#' @return Does not return a value
#' @export
new_conversation <- function() {
  the$responses <- NULL
  the$prompts <- NULL
}


#' Parse response from API functions
#'
#' @param response a response object from \code{\link{chat_api}} or
#'   \code{\link{completions_api}}
#'
#' @return a character vector
#' @export
parse_response <- function(response) {
  # if several answers are requested, collapse into one
  if (isTRUE(response$api == "chat")) {
    return(
      paste(sapply(response[["choices"]], function(x) x[["message"]][["content"]]),
            collapse = "\n\n")
    )
  } else {
    return(paste(sapply(response[["choices"]], `[[`, "text"), collapse = "\n\n"))
  }
}


#' Estimate token count
#'
#' @details This function estimates how many tokens the API will make of the
#' input words. For the models 1 word is more than one token. The default
#' multiplier value resulted from testing the API. See
#' <https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them>
#' for more information.
#'
#'
#' @param x character vector
#' @param mult the multiplier used
#'
#' @return a integer vector of token counts
#' @export
#'
#' @examples
#' estimate_token("this is a test")
estimate_token <- function(x, mult = 1.6) {
  ceiling(vapply(gregexpr("\\S+", x), length, FUN.VALUE = integer(1L)) * mult)
}


# internal function to format answers
screen_answer <- function(x) {
  pars <- unlist(strsplit(x, "\n", fixed = TRUE))
  cli::cli_h1("Answer")
  # "{i}" instead of i stops glue from evaluating code inside the answer
  for (i in pars) cli::cli_text("{i}")
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
  return(list(context = context, code = code))
}


# log prompts and responses
log_ <- function(prompt, response, loc = Sys.getenv("askgpt_log_location")) {
  the$prompts <- c(the$prompts, prompt)
  the$responses <- c(the$responses, response)
  if (loc != "") {
    con <- file(loc, "ab")
    jsonlite::stream_out(data.frame(prompt = prompt, response = response),
                         con, verbose = FALSE)
    close(con)
  }
}
