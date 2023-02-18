.onAttach <- function(...) {
  cli::cli_alert_info("Hi, this is {.emph askgpt} {cli::symbol$smiley}.")
  cli::cli_li("To start error logging, run {.run [{.fun log_init}](askgpt::log_init())} now.")
  cli::cli_li("To see what you can do use {.help [{.fun ?askgpt}](askgpt::askgpt)}.")
  cli::cli_li("Or just run {.run [{.fun askgpt}](askgpt::askgpt())} with any question you want!")
}
