#' highlight_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_highlight_card_ui <- function(id, heading = NULL, apex_height = "20rem", ...){
  ns <- NS(id)
  tagList(
    highlight_card(
      id = id,
      heading = heading,
      in_body = tags$div(
        class = "mt-0",
        apexcharter::apexchartOutput(ns("c"), height = apex_height)),
      ...
    )
  )
}

#' highlight_card Server Functions
#'
#' @noRd
mod_highlight_card_server <- function(id, var,
                                      period = "month",
                                      n = NULL,
                                      type = "bar",
                                      sparkline.enabled = F,
                                      y_formatter = apexcharter::format_num("")){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    card_data <- reactiveVal(get_series_info(var, period, n))

    output$c <- apexcharter::renderApexchart({

      d <- card_data()
      # We use the format of the first series overall
      y_formatter = apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)

      series <- lapply(d$series, function(x) {
        list(
          name = x$series_name,
          data = x$series_value * d$series[[1]]$series_multiplier
        )
      })

      plot_timeseries(
        x_categories = d$x_datetime,
        series = series[[1]],
        y_formatter = y_formatter,
        type = type,
        sparkline = sparkline.enabled)
    })

  })
}

mod_highlight_card_app <- function(){
  ui <- tabler_page(
    mod_highlight_card_ui(id = "i", heading = "Estimated national revenue")
  )
  server <- function(input, output, session) {
    mod_highlight_card_server("i", "revenue", type = "bar", n = 25, y_formatter = apexcharter::format_num("$,.2r", locale = "en-US"))
  }
  shinyApp(ui, server)
}


highlight_card <- function(id = "",
                           card_class = "col-lg-6",
                           heading = "Card heading",
                           in_body = NULL){
  tags$div(
    class = card_class,
    tags$div(
      class = "card",
      tags$div(
        class = "card-body",
        style = "position: relative;",
        tags$h3(
          class = "card-title",
          heading
        ),
        tags$div(
          class = "in-body",
          in_body
        )
      )
    )
  )
}
