#' Request answer from openai's completions API
#'
#' Mostly used under the hood for \code{\link{askgpt}}.
#'
#' @param prompt character string of the prompt to be completed.
#' @param model character string of the model to be used (defaults to
#'   "text-davinci-003").
#' @param temperature numeric value between 0 and 1 to control the randomness of
#'   the output (defaults to 0.2; lower values like 0.2 will make answers more
#'   focused and deterministic).
#' @param max_tokens The maximum number of tokens to generate in the completion.
#'   2048L is the maximum the models accept.
#' @param api_key set the API key. If NULL, looks for the env OPENAI_API_KEY.
#' @param ... additional parameters to be passed to the API (see [the API
#'   documentation](https://platform.openai.com/docs/api-reference/completions)
#'
#' @details Only a few parameters are implemented by name. Most can be sent
#'   through the \code{...}. For example, you could use the \code{n} parameter
#'   just like this \code{completions_api("The quick brown fox", n = 2)}.
#'
#'   A couple of defaults are used by the package:
#'   \itemize{
#'      \item{the model used by default is "text-davinci-003"}
#'      \item{the default temperature is 0.2}
#'      \item{the default for max_tokens is 2048L}
#'   }
#'
#'   You can configure how \code{\link{askgpt}} makes requests by setting
#'   options that start with \code{askgpt_*}. For example, to use a different
#'   model use \code{options(askgpt_model = "text-curie-001")}. It does not
#'   matter if the API parameter ist listed in the function or not. All are
#'   used.
#'
#' @importFrom rlang `%||%`
#'
#' @return a httr2 response object
#' @export
#'
#' @examples
#' \dontrun{
#' completions_api("The quick brown fox")
#' }
completions_api <- function(prompt,
                            model = NULL,
                            temperature = NULL,
                            max_tokens = NULL,
                            api_key = NULL,
                            ...) {

  model <- model %||% getOption("askgpt_completions_model") %||% "text-davinci-003"
  temperature <- temperature %||% getOption("askgpt_temperature") %||% 0.2
  max_tokens <- max_tokens %||% getOption("askgpt_max_tokens") %||% 2048L
  api_key <- api_key %||% login()

  # collect additional options
  params <- list(...)

  if (!is.null(params$stream)) cli::cli_warn("The streaming feature has been removed from the package.")
  # Todo: find more elegant way to remove these
  params$hist <- NULL
  params$config <- NULL

  askopts <- grep("^askgpt_", names(.Options), value = TRUE) |>
    setdiff(c("askgpt_completions_model", "askgpt_key", "askgpt_temperature",
              "askgpt_max_tokens", "askgpt_stream"))
  for (par in askopts) {
    params[gsub("askgpt_", "", par, fixed = TRUE)] <- getOption(par)
  }

  body <- c(list(
    model = model,
    prompt = prompt,
    temperature = temperature,
    max_tokens = max_tokens
  ), params)

  body <- Filter(Negate(is.null), body)

  req <- httr2::request("https://api.openai.com/v1/completions") |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = glue::glue("Bearer {api_key}")
    ) |>
    httr2::req_body_json(body)

  resp <- httr2::req_perform(req) |>
      httr2::resp_body_json()

  resp$call <- req
  resp$api <- "completions"
  return(resp)
}


#' Request answer from openai's chat API
#'
#' @param config a configuration prompt to tell the model how it should behave.
#'
#' @inheritParams completions_api
#'
#' @return A tibble with available models
#'
#' @importFrom rlang `%||%`
#'
#' @return a httr2 response object
#' @export
#'
#' @examples
#' \dontrun{
#' chat_api("Hi, how are you?", config = "answer as a friendly chat bot")
#' }
chat_api <- function(prompt,
                     model = NULL,
                     config = NULL,
                     max_tokens = NULL,
                     api_key = NULL,
                     ...) {

  model <- model %||% getOption("askgpt_chat_model") %||% "gpt-3.5-turbo"
  config <- config %||% getOption("askgpt_config")
  max_tokens <- max_tokens %||% getOption("askgpt_max_tokens") %||% 2048L
  api_key <- api_key %||% login()

  # collect additional options
  params <- list(...)
  if (!is.null(params$stream)) cli::cli_warn("The streaming feature has been removed from the package.")
  askopts <- grep("^askgpt_", names(.Options), value = TRUE) |>
    setdiff(c("askgpt_chat_model", "askgpt_key", "askgpt_config",
              "askgpt_temperature", "askgpt_max_tokens", "askgpt_stream"))
  for (par in askopts) {
    params[gsub("askgpt_", "", par, fixed = TRUE)] <- getOption(par)
  }

  hist <- params$hist %||% c(rbind(prompt_history(), response_history()))
  params$hist <- NULL

  messages <- dplyr::bind_rows(list(
    if (!is.null(config)) data.frame(role = "system",
                                     content = config),
    if (length(hist) > 0) data.frame(role = c("user", "assistant"),
                                     content = hist),
    if (!methods::is(prompt, "data.frame")) data.frame(role = "user",
                                                       content = prompt) else prompt
  ))

  body <- c(list(
    model = model,
    messages = messages,
    max_tokens = max_tokens
  ), params)

  body <- Filter(Negate(is.null), body)

  req <- httr2::request("https://api.openai.com/v1/chat/completions") |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = glue::glue("Bearer {api_key}")
    ) |>
    httr2::req_body_json(body) |>
    httr2::req_error(body = error_body)

  resp <- httr2::req_perform(req) |>
    httr2::resp_body_json()
  resp$call <- req
  resp$api <- "chat"
  return(resp)
}

error_body <- function(resp) {
  httr2::resp_body_json(resp)$error$message
}


#' List Models
#'
#' List the models available in the API. You can refer to the [Models
#' documentation](https://platform.openai.com/docs/models) to understand what
#' models are available and the differences between them.
#'
#'
#' @inheritParams completions_api
#'
#' @return A tibble with available models
#'
#' @importFrom rlang `%||%`
#'
#' @export
#'
#' @examples
#' \dontrun{
#' completions_api("The quick brown fox")
#' }
list_models <- function(api_key = NULL) {

  api_key <- api_key %||% login()

  req <- httr2::request("https://api.openai.com/v1/models") |>
    httr2::req_method("GET") |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = glue::glue("Bearer {api_key}")
    )

  resp <- httr2::req_perform(req) |>
    httr2::resp_body_json()

  dplyr::bind_rows(resp$data)
}
