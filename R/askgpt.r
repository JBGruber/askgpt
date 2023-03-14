#' Ask openai's GPT models a question
#'
#' @param prompt What you want to ask
#' @param chat whether to use the chat API (i.e., the same model as ChatGPT) or
#'   the completions API.
#' @param stream Return pieces of the answer to the screen instead of waiting
#'   for the request to be completed.
#' @param progress Show a progress spinner while the request to the API has not
#'   been fullfilled.
#' @param return_answer Should the answer be returned as an object instead of
#'   printing it to the screen?
#' @param ... additional options forwarded to \code{\link{chat_api}} or
#'   \code{\link{completions_api}} respectively.
#'
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
                   stream = FALSE,
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

  traceback_trigger <- c(
    "Can you elaborate on that?",
    "What?"
  )

  if (prompt %in% traceback_trigger) {
    prompt <- glue::glue("{prompt_history(1L)}",
                         "\n{response_history(1L)}",
                         "\nCan you elaborate on that?")
  }

  callfun <- ifelse(chat, chat_api, completions_api)

  if (stream) {

    cli::cli_h1("Answer")
    response <- callfun(
      prompt = prompt,
      stream = stream,
      ...
    )

  } else if (progress) {

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

  # if several answers are requested, collapse into one
  if (chat) {
    out <- paste(sapply(response[["choices"]], function(x) x[["message"]][["content"]]),
                 collapse = "\n\n")
  } else {
    out <- paste(sapply(response[["choices"]], `[[`, "text"), collapse = "\n\n")
  }

  the$prompts <- c(the$prompts, prompt)
  the$responses <- c(the$responses, out)
  if (interactive()) cli::cli_progress_done()

  if (return_answer) {
    return(c(trimws(out)))
  } else if (!stream) {
    cli::cli_h1("Answer")
    cli::cli_inform(c(trimws(out)))
  }
  invisible(response)
}
