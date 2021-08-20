#' highlight_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_highlight_card_ui <- function(id, apex_height = "20rem", ...){
  ns <- NS(id)
  tagList(
    highlight_card(
      id = id,
      heading = textOutput(ns("h"), inline = TRUE),
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

    card_data <- reactiveVal(get_summary_info(var, period, n))

    output$h <- renderText({
      d <- card_data()
      d$series_name
    })

    output$c <- apexcharter::renderApexchart({

      d <- card_data()

      a <- apexcharter::apexchart() %>%
        apexcharter::ax_chart(
          type = type,
          toolbar = list(show = FALSE),
          sparkline = list(enabled = sparkline.enabled),
          animations = list(enabled = FALSE),
          stacked = FALSE,
          selection = list(enabled = FALSE),
          zoom = list(enabled = FALSE)) %>%
        apexcharter::ax_dataLabels(
          enabled = F
        ) %>%
        apexcharter::ax_series(
          list(name = d$series_name,
               data = d$series_y)) %>%
        apexcharter::ax_xaxis(
          type = "datetime",
          categories = d$x_categories,
          labels =  list(rotate = 0,
                         datetimeUTC = FALSE,
                         padding = 0),
          axisBorder = list(
            show = FALSE
          )) %>%
        apexcharter::ax_yaxis(
          labels = list(padding = 4,
                        formatter = y_formatter)) %>%
        apexcharter::ax_tooltip(
          x = list(format = "MMM yy"),
          y = list(formatter = y_formatter)) %>%
        apexcharter::ax_grid(
          strokeDashArray = 4,
          padding = list(
            top = -20, right = 0, left = -4, bottom = -4)) %>%
        apexcharter::ax_plotOptions(
          bar = list(columnWidth = "50%")) %>%
        apexcharter::ax_responsive(
          list(
            breakpoint = 576,
            options = list(
              yaxis = list(show = FALSE)))
        ) %>%
        apexcharter::ax_colors("#206bc4", "#aaaaaa")

      if (type != "bar") {
        a <- a %>%
          apexcharter::ax_stroke(curve = "smooth",
                                 width = "1.5")
      }
      a
    })

  })
}

mod_highlight_card_app <- function(){
  ui <- tabler_page(
    mod_highlight_card_ui(id = "i")
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
