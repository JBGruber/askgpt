#' Log in to OpenAI
#'
#' @param api_key API key to use for authentication. If not provided, the
#'   function look for a cached key or guide the user to obtain one.
#' @param force_refresh Log in again even if an API key is already cached.
#' @param cache_dir dir location to save keys on disk. The default is to use
#'   \code{rappdirs::user_cache_dir("askgpt")}.
#' @param no_cache Don't cache the API key, only load it into the environment.
#'
#' @return a character vector with an API key
#' @export
login <- function(api_key,
                  force_refresh = FALSE,
                  cache_dir = NULL,
                  no_cache = FALSE) {

  if (is.null(cache_dir)) cache_dir <- rappdirs::user_cache_dir("askgpt")

  # try get key from env
  if (missing(api_key)) api_key <- Sys.getenv("OPENAI_API_KEY")

  # try to load cached key
  if (api_key == "") api_key <- load_key(cache_dir)

  # prompt user to retrieve key
  if ((api_key == "" || force_refresh) && interactive()) api_key <- key_menu()

  if (api_key == "") cli::cli_abort("No API key available")

  # cache secret
  if ((length(list.files(cache_dir, full.names = TRUE)) == 0L || force_refresh) &&
      !no_cache) cache_secret(api_key, cache_dir)

  Sys.setenv(OPENAI_API_KEY = api_key)
  invisible(api_key)
}


key_menu <- function() {
  utils::browseURL("https://platform.openai.com/account/api-keys")

  cli::cli_div(theme = list(span.button = list("background-color" = "#ECECF1",
                                               color = "#5C5D65")))
  cli::cli_alert_info("It looks like you have not provided an API key yet.",
                      "Let me guide you through the process:")
  cli::cli_ol(c(
    "Go to {.url https://platform.openai.com/account/api-keys}",
    "(Log into your account if you haven't done so yet)",
    "On the site, click the button {.button + Create new secret key} to create an API key",
    "Copy this key into R/RStudio"
  ))
  if (rstudio_available()) {
    api_key <- rstudioapi::askForSecret("api_key", message = "Enter OpenAI secret API key: ")
  } else {
    api_key <- readline(prompt = "Enter OpenAI secret API key: ")
  }
  return(api_key)
}


load_key <- function(cache_dir) {
  api_key <- ""
  cache <- list.files(cache_dir,
                      full.names = TRUE)
  if (length(cache) > 0L) api_key <- httr2::secret_read_rds(cache, I(rlang::hash(Sys.info()[["user"]])))
  return(api_key)
}


cache_secret <- function(api_key, cache_dir) {
  dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
  httr2::secret_write_rds(
    api_key,
    path = file.path(cache_dir,
                     "api_key.rds.enc"),
    key = I(rlang::hash(Sys.info()[["user"]]))
  )
}
