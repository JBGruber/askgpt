#' Ask openai's GPT models a question
#'
#' @param prompt What you want to ask
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

  cli::cli_progress_step("GPT is thinking {cli::pb_spin}")

  the$prompts <- c(the$prompts, prompt)

  rp <- callr::r_bg(function(x) {
    openai::create_completion(
      model = "text-davinci-003",
      prompt = x,
      max_tokens = 500,
      temperature = 0.1
    )
  }, args = list(prompt))

  while (rp$is_alive()) cli::cli_progress_update(); Sys.sleep(2/100)

  response <- rp$get_result()
  the$responses <- c(the$responses, response[["choices"]][["text"]])
  cli::cli_progress_done()

  if (return_answer) {
    return(c(trimws(response[["choices"]][["text"]])))
  } else {
    cli::cli_h1("Answer")
    cli::cli_inform(c(trimws(response[["choices"]][["text"]])))
  }
}
