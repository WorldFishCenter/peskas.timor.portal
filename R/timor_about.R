#' text_panel UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
peskas_timor_about_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    class = "page-body",
    tags$div(
      class = "container-xl",
      tags$div(
        class = "row justify-content-center",
        tags$div(
          class = "col-lg-10 col-xl-9",
          tags$div(
            class = "card card-lg",
            tags$div(
              class = "card-body markdown",
              htmlOutput(ns("about"))
            )
          )
        )
      )
    )
  )
}

#' text_panel Server Functions
#'
#' @noRd
timor_about_server <- function(id, content, i18n_r = reactive(list(t = function(x) x))) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$about <- renderUI({
      markdown(i18n_r()$t(content))
    })
  })
}

