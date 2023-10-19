#' mod_region_conservation_ui UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_region_conservation_ui <- function(id, heading = NULL, subheading = NULL, apex_height = "20rem", ...) {
  ns <- NS(id)

  tagList(
    highlight_card_narrow(
      id = id,
      card_class = "col-12",
      heading = heading,
      subheading = subheading,
      in_body = tags$div(
        class = "mt-0",
        uiOutput(ns("c"), height = apex_height)
      ),
      ...
    )
  )
}

#' mod_region_conservation Server Functions
#'
#' @noRd
mod_region_conservation_server <- function(id,
                                           xvar,
                                           yvar,
                                           fillvar,
                                           legend_position,
                                           legend_align,
                                           legend_fontsize,
                                           col_length,
                                           y_formatter,
                                           i18n_r = reactive(list(t = function(x) x))) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns


    output$c <- renderUI({
      data <- peskas.timor.portal::summary_data$conservation %>%
        dplyr::mutate(
          perc = round(perc, 2),
          conservation_place = as.factor(conservation_place)
        ) %>%
        na.omit()

      data$conservation_place <- i18n_r()$t(as.character(data$conservation_place))

      x <- rlang::enquo(arg = xvar)
      y <- rlang::enquo(arg = yvar)
      group <- rlang::enquo(arg = fillvar)

      output$char <- apexcharter::renderApexchart({
        apex_bar_stacked(
          plot_data = data,
          xvar = x,
          yvar = y,
          fillvar = group,
          legend_position,
          legend_align,
          legend_fontsize,
          col_length,
          y_formatter
        )
      })
    })
    apexcharter::apexchartOutput(ns("char"))
  })
}
