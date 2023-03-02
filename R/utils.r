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
#' @export
log_init <- function(...) {
  if (!isTRUE(the$log_init)) global_entrace(...)
  the$log_init <- TRUE
}


#' Return the prompt/response history
#'
#' @param n number of prompts/responses to return.
#'
#' @export
prompt_history <- function(n = Inf) {
  return(utils::tail(the$prompts, n))
}


#' @inherit prompt_history
response_history <- function(n = Inf) {
  return(utils::tail(the$responses, n))
}
