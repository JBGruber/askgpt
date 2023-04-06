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
    c("shiny", "miniUI", "shinycssloaders", "shinyjs"),
    "in order to use the tutorialise addin"
  )

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
        value = "Turn this into a tutorial for beginners and explain how this code works, return it as an R Markdown document:",
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
        out <- make_request(input$prompt, input$code)
        f <- tempfile("tutorial_", tmpdir = ".", fileext = ".rmd")
        writeLines(out, f)
        rstudioapi::documentOpen(f)
      })
    })

  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  invisible(shiny::runGadget(app, viewer = shiny::dialogViewer("Tutorialise R Code using ChatGPT")))

}


make_request <- function(prompt, code) {

  parse_response(chat_api(prompt = prompt))

}


rstudio_selection <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  out <- context$selection[[1L]]$text
  if (isTRUE(out == "") | length(out) == 0) out <- context$contents
  if (isTRUE(out == "") | length(out) == 0) out <- rstudioapi::getSourceEditorContext()$contents
  if (isTRUE(out == "") | length(out) == 0) out <- ""
  return(paste(out, collapse = "\n"))
}
