#' Log in to OpenAI
#'
#' @param api_key API key to use for authentication. If not provided, the
#'   function look for a cached key or guide the user to obtain one.
#' @param force_refresh Log in again even if a valid API key is already
#'   cached.
#' @param no_cache Don't cache the API key, only load it into the environment.
#'
#' @export
login <- function(api_key,
                  force_refresh = FALSE,
                  no_cache = FALSE) {
  # try get key from env
  if (missing(api_key)) {
    api_key <- Sys.getenv("OPENAI_API_KEY")
    # don't automatically save env tokens
    no_cache <- TRUE - no_cache
  }

  # try to load cached key
  if (api_key == "") {
    cache <- list.files(rappdirs::user_cache_dir("askgpt"),
                        full.names = TRUE)
    if (length(cache) > 0L) api_key <- httr2::secret_read_rds(cache, I(rlang::hash(Sys.info()[["user"]])))
  }

  # prompt user to retrieve key
  if (api_key == "" | force_refresh) {

    utils::browseURL("https://platform.openai.com/account/api-keys")

    cli::cli_div(theme = list(span.button = list("background-color" = "#ECECF1", color = "#5C5D65")))
    cli::cli_alert_info("It looks like you have not provided an API key yet. Let me guide you through the process:")
    cli::cli_ol(c(
      "Go to {.url https://platform.openai.com/account/api-keys}",
      "(Log into your account if you haven't done so yet)",
      "On the site, click the button {.button + Create new secret key} to create an API key",
      "Copy this key into R/RStudio"
    ))
    if (rlang::is_installed("rstudioapi")) {
      api_key <- rstudioapi::askForSecret("api_key", message = "Enter OpenAI secret API key: ")
    } else {
      api_key <- readline(prompt = "Enter OpenAI secret API key: ")
    }

  }

  # cache secret
  if ((length(list.files(rappdirs::user_cache_dir("askgpt"))) == 0L | force_refresh) &
      no_cache) {

    dir.create(rappdirs::user_cache_dir("askgpt"), showWarnings = FALSE, recursive = TRUE)
    httr2::secret_write_rds(
      api_key,
      path = file.path(rappdirs::user_cache_dir("askgpt"),
                       "api_key.rds.enc"),
      key = I(rlang::hash(Sys.info()[["user"]]))
    )

  }

  Sys.setenv(OPENAI_API_KEY = api_key)
  invisible(api_key)
}
