#' Turn R code into a tutorial
#'
#' @description `tutorialise_addin()` opens an [RStudio
#'   gadget](https://shiny.rstudio.com/articles/gadgets.html) and
#'   [addin](http://rstudio.github.io/rstudioaddins/) that turns selected code
#'   into an R Markdown/Quarto Tutorial.
#'
#' @return No return value, opens a new file in RStudio
tutorialise_addin <- function() {

  rlang::check_installed(
    c("shiny", "miniUI", "shinycssloaders"),
    "in order to use the tutorialise addin"
  )

  p <- the$tutorialise_prompt
  if (is.null(p)) p <- "Turn this into a tutorial for beginners and explain how this code works, return it as an R Markdown document:"

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar(
      shiny::p(
        "Turn this code into a Tutorial"
      ),
      right = miniUI::miniTitleBarButton("done", "Tutorialise!", primary = TRUE)
    ),
    miniUI::miniContentPanel(
      shinycssloaders::withSpinner(shiny::textOutput("spinner"), type = 7, size = 3),
      shiny::textInput(
        "prompt",
        "Prompt",
        value = p,
        width = "100%"
      ),
      shiny::tags$hr(),
      shiny::textAreaInput(
        "code",
        "Use this code?",
        value = rstudio_selection(),
        width = "100%",
        height = "400px"
      )
    )
  )

  server <- function(input, output, session) {

    # does not really render text but needed to show spinner
    prcs <- shiny::eventReactive(input$done, "GPT is thinking")
    output$spinner <- shiny::renderText({
      prcs()
      shiny::stopApp({
        the$tutorialise_prompt <- input$prompt
        out <- make_request(input$prompt, input$code)
        f <- paste0("tutorial_", gsub(pattern = "\\s+", "-", substr(input$prompt, 1, 50)), ".rmd")
        writeLines(out, f)
        rstudioapi::documentOpen(f)
      })
    })

  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  invisible(shiny::runGadget(app, viewer = shiny::dialogViewer("Tutorialise R Code using ChatGPT")))

}


#' Improve code/documentation/writing using a prompt
#'
#' @description `tutorialise_addin()` opens an [RStudio
#'   gadget](https://shiny.rstudio.com/articles/gadgets.html) and
#'   [addin](http://rstudio.github.io/rstudioaddins/) that can be used to
#'   improve existing code, documentation, or writing.
#'
#' @return No return value, opens a new file in RStudio
improve_addin <- function() {

  rlang::check_installed(
    c("shiny", "miniUI", "shinycssloaders"),
    "in order to use the tutorialise addin"
  )

  p <- the$improve_prompt
  if (is.null(p)) p <- "Improve this code/documentation/writing:"

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar(
      shiny::p(
        "Improve code/documentation/writing"
      ),
      right = miniUI::miniTitleBarButton("done", "Improve!", primary = TRUE)
    ),
    miniUI::miniContentPanel(
      shinycssloaders::withSpinner(shiny::textOutput("spinner"), type = 7, size = 3),
      shiny::textInput(
        "prompt",
        "Prompt",
        value = p,
        width = "100%"
      ),
      shiny::tags$hr(),
      shiny::textAreaInput(
        "code",
        "Use this?",
        value = rstudio_selection(),
        width = "100%",
        height = "400px"
      )
    )
  )

  server <- function(input, output, session) {

    # does not really render text but needed to show spinner
    prcs <- shiny::eventReactive(input$done, "GPT is thinking")
    output$spinner <- shiny::renderText({
      prcs()
      shiny::stopApp({
        the$improve_prompt <- input$prompt
        out <- make_request(input$prompt, input$code)
        f <- tempfile(fileext = ".txt")
        writeLines(out, f)
        rstudioapi::documentOpen(f)
      })
    })

  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  invisible(shiny::runGadget(app, viewer = shiny::dialogViewer("Improve input using ChatGPT")))

}


#' @importFrom rlang `%||%`
make_request <- function(prompt, code) {

  # break into API size pieces
  mod <- getOption("askgpt_chat_model") %||% "gpt-3.5-turbo"
  max_tokens <- getOption("askgpt_max_tokens") %||% 2048L
  tok_max <- askgpt::token_limits[askgpt::token_limits$model == mod, "limit"] - max_tokens

  tokens <- estimate_token(paste(prompt, code))

  if (tokens > tok_max) {
    cli::cli_alert_info(
      c("The request is too long and is split into several prompts, which can take a ",
        "long time to process. The final tutorial will have a line with `----` where ",
        "responses were combined."), wrap = TRUE
      )

    # split into paragraphs
    prompts <- split_prompt(code, tok_max = tok_max - estimate_token(prompt))
    # glue prompts + this is the nth part + code chunk
    prompts <- vapply(seq_along(prompts), function(i) {
      glue::glue("{prompt}. This is the {i}th part of the code:\n{prompts[i]}")
    }, FUN.VALUE = character(1L))

    vapply(prompts, function(prompt) {
      parse_response(chat_api(prompt = prompt))
    }, FUN.VALUE = character(1L)) |>
      paste(collapse = "\n----\n")
  } else {
    prompt <- paste0(prompt, "\n", code)
    parse_response(chat_api(prompt = prompt))
  }
}

# split long prompts
split_prompt <- function(x, tok_max) {
  pars <- strsplit(x, "\n")[[1]]
  lens  <- estimate_token(pars)
  # leave a margin of 20 for safety
  bins <- cumsum(lens) %/% tok_max + 20
  split_pars <- split(pars, bins)
  vapply(split_pars, paste, collapse = "\n", FUN.VALUE = character(1))
}


rstudio_selection <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  out <- context$selection[[1L]]$text
  if (isTRUE(out == "") || length(out) == 0) out <- context$contents
  if (isTRUE(out == "") || length(out) == 0) out <- rstudioapi::getSourceEditorContext()$contents
  if (isTRUE(out == "") || length(out) == 0) out <- ""
  return(paste(out, collapse = "\n"))
}
