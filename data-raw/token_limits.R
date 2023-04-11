library(rvest)
read_html("https://platform.openai.com/docs/models/gpt-3") %>%
  html_elements("table")
## code to prepare `token_limits` dataset
token_limits <- data.frame(
  model = c("gpt-3.5-turbo", "gpt-3.5-turbo-0301", "gpt-4", "gpt-4-0314", "gpt-4-32k", "gpt-4-32k-0314"),
  limit = c(4096L, 4096L, 8192L, 8192L, 32768L, 32768L)
)
usethis::use_data(token_limits, overwrite = TRUE)
