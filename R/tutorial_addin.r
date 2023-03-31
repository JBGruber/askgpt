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
    c("shiny", "miniUI"),
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
      shiny::textAreaInput(
        "code",
        "Use this code?",
        value = rstudio_selection(),
        width = "100%"
      ),
      shiny::textInput(
        "target",
        "Use this target audiece?",
        value = "beginners",
        width = "100%"
      ),
      shiny::textInput(
        "goal",
        "Use this goal?",
        value = "how this code works",
        width = "100%"
      ),
      shiny::tags$hr(),
      shiny::actionButton("preview_button", "Preview prompt"),
      shiny::textAreaInput(
        "prompt",
        "Prompt Preview",
        width = "100%",
        height = "400px"
      ),
    )
  )

  server <- function(input, output, session) {

    build_prompt <- shiny::eventReactive(input$preview_button, {
      prompt_template(input$code, input$target, input$goal)
    })

    shiny::observeEvent(input$preview_button, {
      shiny::updateTextInput(session, "prompt", value = build_prompt())
    })

    shiny::observeEvent(input$done, {
      shiny::stopApp({
        p <- ifelse(input$prompt == "",
                    prompt_template(input$code, input$target, input$goal),
                    input$prompt)
        build_tutorial(p)
      })
    })
  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  shiny::runGadget(app, viewer = shiny::dialogViewer("Tutorialise R Code using ChatGPT"))

}


build_tutorial <- function(prompt) {
  out <- askgpt(prompt, chat = FALSE, stream = FALSE, return_answer = TRUE)
  f <- tempfile("tutorial_", tmpdir = ".", fileext = ".rmd")
  writeLines(out, f)
  rstudioapi::documentOpen(f)
}

prompt_template <- function(code, target, goal) {
  glue::glue("Turn this into a tutorial for {target} and explain {goal}, ",
             "return it as an R Markdown document:",
             "\n{code}")
}

rstudio_selection <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  out <- context$selection[[1L]]$text
  if (out == "") out <- context$contents
  return(out)
}
