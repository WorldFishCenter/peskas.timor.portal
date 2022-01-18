#peskas_timor_about <- function(){
#  markdown(pars$about$text)
#}


peskas_timor_about_ui <- function(id) {
  ns <- NS(id)
  tags$div(
    class = "col-lg-9",
    tags$div(
      class = "card card-lg",
      tags$div(
        class = "card-body",
        tags$div(
          class = "markdown",
          tags$div(tags$div(
            class = "d-flex mb-3",
            htmlOutput(ns("about"))
           )
          )
        )
      )
    )
  )
}

#peskas_timor_about <- function(){
#  page_text(content = timor_about_ui(id = "about-text"))
#}

#timor_about_ui <- function(id){
#  ns <- NS(id)
#  htmlOutput(ns("about-text"))
#}

timor_about_server <- function(id, content, i18n_r = reactive(list(t = function(x) x))) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$about <- renderUI({
      markdown(i18n_r()$t(content))
    })
  })
}

