#' simple_summary_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_simple_summary_card_ui <- function(id, div_class = "col-md-3", card_style = "min-height: 4rem"){
  ns <- NS(id)

  tags$div(
    class = div_class,
    tags$div(
      class = "card",
      style = card_style,
      uiOutput(ns("o"))
    )
  )
}

#' simple_summary_card Server Functions
#'
#' @noRd
mod_simple_summary_card_server <- function(id, var, period = "month", n = 2, year = NULL,  i18n_r = reactive(list(t = function(x) x))){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$o <- renderUI({
      info <- get_series_info(var, period, n, year, region = input$muni)
      simple_card_content_ui(
        icon_ui = simple_card_icon_ui(direction = info$series[[1]]$trend_direction),
        heading = d3.format::d3.format(info$series[[1]]$series_format)(info$series[[1]]$last_period_val),
        subheading = i18n_r()$t(info$series[[1]]$series_name),
        trend_ui = simple_card_trend_ui(
          trend = info$series[[1]]$trend_magnitude,
          direction = info$series[[1]]$trend_direction),
        top_right_element = info$series[[1]]$last_period
      )
    })

  })
}


mod_simple_summary_card_app <- function(){
  ui <- tabler_page(
    mod_simple_summary_card_ui(id = "i"),
    mod_simple_summary_card_ui(id = "i2"),
    mod_simple_summary_card_ui(id = "i3"),
    mod_simple_summary_card_ui(id = "i4")
  )
  server <- function(input, output, session) {
    mod_simple_summary_card_server("i", "n_matched", n = 2)
    mod_simple_summary_card_server("i2", "revenue", n = 2)
    mod_simple_summary_card_server("i3", "n_landings", n = 2)
    mod_simple_summary_card_server("i4", "n_boats", period = "year", n = 2)
  }
  shinyApp(ui, server)
}

simple_card_content_ui <- function(icon_ui = simple_card_icon_ui(),
                                   heading = "Card heading",
                                   subheading = "Card subheading",
                                   trend_ui = simple_card_trend_ui(),
                                   top_right_element = ""){

  tags$div(
    class = "card-body",
    tags$div(
      class = "row align-items-center",
      tags$div(
        class = "col-auto",
        icon_ui
      ),
      tags$div(
        class = "col",
        tags$div(
          class = "d-flex align-items-center",
          tags$div(
            class = "font-weight-medium",
            subheading
          ),
          tags$div(
            class = "ms-auto lh-1 text-muted small",
            top_right_element
          )
        ),
        tags$div(
          class = "d-flex align-items-center",
          tags$div(
            class = "h1 mb-0",
            heading
          ),
          tags$div(
            class = "me-auto",
            trend_ui
          )
        )
      )
    )
  )
}

simple_card_icon_ui <- function(direction = c("none", "up","down")){
  icon <- trend_icon(direction, style = "arrow")
  color <- trend_color(direction)
  tags$span(
    class = paste(color$background, "avatar"),
    icon
  )
}

simple_card_trend_ui <- function(trend = "0%", direction = c("none", "up","down")){
  color <- trend_color(direction)
  tags$span(
    class = paste("ms-2 float-right font-weight-medium lh-1", color$text),
    trend
  )
}
