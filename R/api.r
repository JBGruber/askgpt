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
#' @param stream logical value to indicate whether the response should be
#'   streamed.
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
#'      \item{the default for stream is FALSE}
#'   }
#'
#'   You can configure how \code{\link{askgpt}} make requests by setting options
#'   that start with \code{askgpt_*}. For example, to use a different model use
#'   \code{options(askgpt_model = "text-curie-001")}. It does not matter if the
#'   API parameter ist listed in the function or not. All are used.
#'
#' @importFrom rlang `%||%`
#'
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
                            stream = NULL,
                            api_key = NULL,
                            ...) {

  options(askgpt_model = "text-davinci-003")


  model <- model %||% getOption("askgpt_model") %||% "text-davinci-003"
  temperature <- temperature %||% getOption("askgpt_temperature") %||% 0.2
  max_tokens <- max_tokens %||% getOption("askgpt_max_tokens") %||% 2048L
  stream <- stream %||% getOption("askgpt_stream") %||% FALSE
  api_key <- api_key %||% login()

  # collect additional options
  params <- list(...)
  askopts <- grep("^askgpt_", names(.Options), value = TRUE) |>
    setdiff(c("askgpt_model", "askgpt_key"))
  for (par in askopts) {
    params[gsub("askgpt_", "", par, fixed = TRUE)] <- getOption(par)
  }

  req <- httr2::request("https://api.openai.com/v1/completions") |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = glue::glue("Bearer {api_key}")
    ) |>
    httr2::req_body_json(c(list(
      model = model,
      prompt = prompt,
      temperature = temperature,
      max_tokens = max_tokens,
      stream = stream
    ), params))

  if (stream) {
    the$temp_response <- NULL
    resp <- httr2::req_stream(req, stream_response)
    # for conformity with regular response
    resp <- list(choices = list(list(text = the$temp_response)))
  } else {
    resp <- httr2::req_perform(req) |>
      httr2::resp_body_json()
  }
  return(resp)
}

stream_response <- function(x) {
  res <- rawToChar(x)
  if (grepl("^\\{\\n\\s*\"error\":\\s*\\{", res)) {

    error <- jsonlite::fromJSON(res)
    cli::cli_abort("API returned an error: {error$error$message} [{error$error$type}]")

  } else {

    response <- gsub("data: ", "", res, fixed = TRUE)
    response <- gsub("[DONE]", "", response, fixed = TRUE)
    response <- jsonlite::stream_in(textConnection(response),  verbose = FALSE)
    response <- paste(sapply(response[["choices"]], `[[`, "text"), collapse = "")
    the$temp_response <- c(the$temp_response, response)
    cli::cli_inform(c(trimws(response)))

  }
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
