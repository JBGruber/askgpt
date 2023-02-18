#' Request answer from openai's completions API
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
                            temperature = 0.2,
                            max_tokens = 2048L,
                            stream = FALSE,
                            api_key = NULL,
                            ...) {

  key <- api_key %||% Sys.getenv("OPENAI_API_KEY")

  model <- model %||% "text-davinci-003"

  req <- httr2::request("https://api.openai.com/v1/completions") |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = glue::glue("Bearer {key}")
    ) |>
    httr2::req_body_json(list(
      model = model,
      prompt = prompt,
      temperature = temperature,
      max_tokens = max_tokens,
      stream = stream
    ))

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

