#' Ask openai's GPT models a question
#'
#' @param prompt What you want to ask
#' @param stream Return pieces of the answer to the screen instead of waiting
#'   for the request to be completed.
#' @param return_answer Should the answer be returned as an object instead of
#'   printing it to the screen?
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
                   stream = FALSE,
                   return_answer = FALSE) {

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

  the$prompts <- c(the$prompts, prompt)

  if (stream) {

    cli::cli_h1("Answer")
    response <- completions_api(
      prompt = prompt,
      stream = stream
    )

  } else {

    cli::cli_progress_step("GPT is thinking {cli::pb_spin}")

    rp <- callr::r_bg(completions_api,
                      args = list(prompt = prompt),
                      package = TRUE)

    while (rp$is_alive()) cli::cli_progress_update(); Sys.sleep(2/100)

    response <- rp$get_result()

  }

  # if several answers are requested, collapse into one
  out <- paste(sapply(response[["choices"]], `[[`, "text"), collapse = "\n\n")
  the$responses <- c(the$responses, out)
  cli::cli_progress_done()

  if (return_answer) {
    return(c(trimws(out)))
  } else if (!stream) {
    cli::cli_h1("Answer")
    cli::cli_inform(c(trimws(out)))
  }
  invisible(response)
}
