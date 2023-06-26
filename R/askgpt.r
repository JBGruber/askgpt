#' Ask openai's GPT models a question
#'
#' @param prompt What you want to ask
#' @param chat whether to use the chat API (i.e., the same model as ChatGPT) or
#'   the completions API.
#' @param progress Show a progress spinner while the request to the API has not
#'   been fulfilled.
#' @param return_answer Should the answer be returned as an object instead of
#'   printing it to the screen?
#' @param ... additional options forwarded to \code{\link{chat_api}} or
#'   \code{\link{completions_api}} respectively.
#'
#' @return either an httr2 response from one of the APIs or a character vector
#'   (if return_answer).
#' @export
#'
#' @examples
#' \dontrun{
#' askgpt("What is an R function?")
#' askgpt("What is wrong with my last command?")
#' askgpt("Can you help me with the function aes() from ggplot2?")
#' }
askgpt <- function(prompt,
                   chat = TRUE,
                   progress = TRUE,
                   return_answer = FALSE,
                   ...) {

  traceback_trigger <- c(
    "What is wrong with my last command?",
    "help!"
  )

  if (prompt %in% traceback_trigger) {
    rrr <- rlang::last_error()
    prompt <- glue::glue("explain why this R code does not work:",
                         "\n{rlang::expr_deparse(rrr[['call']])}",
                         "\n{rlang::expr_deparse(rrr[['message']])}")
  }

  callfun <- ifelse(chat, chat_api, completions_api)
  # api function can be replaced with random function (for testing)
  if ("callfun" %in% names(list(...))) callfun <- list(...)$callfun

  if (progress) {

    if (interactive()) cli::cli_progress_step("GPT is thinking {cli::pb_spin}")
    key <- login()

    rp <- callr::r_bg(callfun,
                      args = list(prompt = prompt,
                                  api_key = key,
                                  config = getOption("askgpt_config"),
                                  hist = c(rbind(prompt_history(), response_history())),
                                  ...),
                      package = TRUE)

    if (interactive()) while (rp$is_alive()) {
      cli::cli_progress_update()
      Sys.sleep(2 / 100)
    }

    response <- rp$get_result()

  } else {
    response <- callfun(
      prompt = prompt,
      ...
    )
  }

  out <- parse_response(response)

  log_(prompt, out)
  if (interactive()) cli::cli_progress_done()

  if (return_answer) {
    return(out)
  } else {
    screen_answer(out)
    invisible(response)
  }
}
