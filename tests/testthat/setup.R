cache_response <- function(req) {

  prompt <- req[["body"]][["data"]][["prompt"]]
  if (is.null(prompt)) prompt <- tail(req[["body"]][["data"]][["messages"]][, 2], 1)

  id <- paste0(req[["body"]][["data"]][["model"]], "_", substr(gsub("[ ?:\n]", "", prompt), 1, 25), ".rds")
  path <- file.path("./responses", id)

  if (file.exists(path)) {
    resp <- readRDS(path)
  } else {
    message("mock cache does not exist, saving to ", path)
    resp <- withr::with_options(list(httr2_mock = NULL), httr2::req_perform(req))
    dir.create("responses", showWarnings = FALSE)
    saveRDS(resp, path)
  }
  return(resp)
}


mockcall <- function(...) {
  list(
    api = "chat",
    choices = list(list(message = list(content = "test")))
  )
}

mock_error <- function(req) {
  httr2::response(
    429,
    method = "POST",
    headers = list("content-type" = "application/json; charset=utf-8"),
    body = charToRaw(jsonlite::toJSON(list(error = list(message = "test"))))
  )
}

