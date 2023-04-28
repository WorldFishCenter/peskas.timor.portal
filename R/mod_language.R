#' language UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' Outside of this module, the app must contain a globally accessible i18n translation object
#' (shiny.i18n::Translator$new) and a call to shiny.i18n::usei18n
#'
#' @importFrom shiny NS tagList
#' @noRd
mod_language_ui <- function(id) {
  ns <- NS(id)

  # i18n <<- shiny.i18n::Translator$new(
  # translation_json_path = system.file("translation.json", package = "peskas.timor.portal"))

  tagList(
    selectInput(
      inputId = ns("language"),
      label = tags$span(
        icon_world(),
        i18n$t(pars$settings$language_select$label$text),
        # tags$span(class = "badge bg-red-lt ms-2", "Experimental"),
        class = "form-label"
      ),
      choices = c("English" = "eng", "Portugu\u00eas" = "por", "Tetun" = "tet"),
      selected = i18n$get_key_translation(), width = "100%"
    )
  )
}

#' language Server Functions This_session is used to provide access to the
#' global session, not just that of the module. That ensures that the browser
#' based translations work as well
#' @noRd
mod_language_server <- function(id, this_session = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    if (is.null(this_session)) {
      this_session <- session
    }

    i18n_r <- reactive({
      selected <- input$language

      if (length(selected) > 0 && selected %in% i18n$get_languages()) {
        # For translationsin the browser
        this_session$sendInputMessage("i18n-state", list(lang = selected))
        # For translations made in the server (e.g. inside modules with reactive
        # outputs)
        i18n$set_translation_language(selected)
      }
      i18n
    })

    i18n_r
  })
}

## To be copied in the UI
# mod_language_ui("language_1")

## To be copied in the server
# mod_language_server("language_1")
