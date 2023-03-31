.onAttach <- function(...) {
  greet_startup()
}

#' @keywords internal
greet_startup <- function() {
  msg <- paste0(
    c(
      "Hi, this is {.emph askgpt} {cli::symbol$smiley}.",
      "{cli::symbol$bullet} To start error logging, run {.run [{.fun log_init}](askgpt::log_init())} now.",
      "{cli::symbol$bullet} To see what you can do use {.help [{.fun ?askgpt}](askgpt::askgpt)}.",
      "{cli::symbol$bullet} Or just run {.run [{.fun askgpt}](askgpt::askgpt())} with any question you want!"
    ),
    collapse = "\n"
  )
  rlang::inform(cli::format_inline(msg), class = "packageStartupMessage")
}
