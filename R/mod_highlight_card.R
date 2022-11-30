#' highlight_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_highlight_card_ui <- function(id, heading = NULL, apex_height = "20rem", ...) {
  ns <- NS(id)
  tagList(
    highlight_card(
      id = id,
      heading = heading,
      in_body = tags$div(
        class = "mt-0",
        apexcharter::apexchartOutput(ns("c"), height = apex_height)
      ),
      ...
    )
  )
}

#' highlight_card Server Functions
#'
#' @noRd
mod_highlight_card_server <- function(id, var, period = "month", n = NULL,
                                      type = "bar",
                                      sparkline.enabled = F,
                                      y_formatter = apexcharter::format_num(""),
                                      ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    card_data <- reactiveVal(get_series_info(var, period, n, ...))

    output$c <- apexcharter::renderApexchart({
      d <- card_data()
      # We use the format of the first series overall
      y_formatter <- apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)

      series <- lapply(d$series, function(x) {
        list(
          name = x$series_name,
          data = x$series_value * d$series[[1]]$series_multiplier
        )
      })

      plot_timeseries(
        x_categories = d$x_datetime,
        series = series,
        y_formatter = y_formatter,
        type = type,
        sparkline = sparkline.enabled
      )
    })
  })
}

mod_highlight_card_app <- function() {
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
                           in_body = NULL,
                           top_right = NULL) {
  tags$div(
    class = card_class,
    tags$div(
      class = "card",
      tags$div(
        class = "card-header mb-3",
        tags$div(
          tags$h3(
            class = "card-title",
            heading
          )
        ),
        tags$div(
          class = "ms-auto lh1",
          style = "line-height:0px;",
          top_right
        )
      ),
      tags$div(
        class = "card-body",
        style = "position: relative;",
        tags$div(
          class = "in-body",
          in_body
        )
      )
    )
  )
}


highlight_card_narrow <- function(id = "",
                                  card_class = "col-lg-6",
                                  heading = "Card heading",
                                  in_body = NULL,
                                  top_right = NULL) {
  tags$div(
    class = card_class,
    tags$div(
      class = "card",
      tags$div(
        class = "card-header mb-1",
        tags$div(
          tags$h3(
            class = "card-title",
            heading
          )
        )
      ),
      tags$div(
        class = "card-body",
        style = "position: relative;",
        tags$div(
          class = "in-body",
          in_body
        )
      )
    )
  )
}


mod_highlight_mun_ui <- function(id, heading = NULL, apex_height = "20rem", ...) {
  ns <- NS(id)

  regions <- unique(peskas.timor.portal::municipal_aggregated$region)

  s <- selectInput(ns("r"),
    label = "",
    choices = c("National", regions),
    selectize = FALSE,
    width = "auto"
  )

  s$children[[2]]$children[[1]] <-
    htmltools::tagAppendAttributes(s$children[[2]]$children[[1]],
      class = "form-select"
    )

  tagList(
    highlight_card(
      id = id,
      heading = heading,
      top_right = s,
      in_body = tags$div(
        class = "mt-0",
        apexcharter::apexchartOutput(ns("cm"), height = apex_height)
      ),
      ...
    )
  )
}


mod_highlight_mun_server <- function(id, var, period = "month", n = NULL,
                                     type = "bar",
                                     sparkline.enabled = F,
                                     y_formatter = apexcharter::format_num(""),
                                     ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    region_in <- reactive({
      req(input$r)
    })

    card_data <- reactive({
      if (region_in() == "National") {
        get_series_info(var, period, n, region = FALSE, ...)
      } else {
        get_series_info(var, period, n, region = input$r, ...)
      }
    })

    output$cm <- apexcharter::renderApexchart({
      d <- card_data()
      # d <- plot_data()
      # We use the format of the first series overall
      y_formatter <- apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)

      series <- lapply(d$series, function(x) {
        list(
          name = x$series_name,
          data = x$series_value * d$series[[1]]$series_multiplier
        )
      })

      plot_timeseries(
        x_categories = d$x_datetime,
        series = series,
        y_formatter = y_formatter,
        type = type,
        sparkline = sparkline.enabled
      )
    })
  })
}


mod_highlight_mun_app <- function() {
  ui <- tabler_page(
    mod_highlight_mun_ui(id = "cm", heading = "Estimated national revenue")
  )
  server <- function(input, output, session) {
    mod_highlight_mun_server("cm", "revenue", type = "bar", n = 40, y_formatter = apexcharter::format_num("$,.2r", locale = "en-US"))
  }
  shinyApp(ui, server)
}
# mod_highlight_mun_app()
