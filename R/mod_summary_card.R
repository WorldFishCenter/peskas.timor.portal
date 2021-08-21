#' summary_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_summary_card_ui <- function(id, apex_height = "4rem", ...){
  ns <- NS(id)
  summary_card(
    id = id,
    subheader = textOutput(ns("s"), inline = TRUE),
    heading = textOutput(ns("h"), inline = TRUE),
    annotation = uiOutput(ns("t")),
    off_body = tags$div(
      class = "mt-0",
      apexcharter::apexchartOutput(ns("c"), height = apex_height)),
    ...)
}

#' summary_card Server Functions
#'
#' @noRd
#' @import data.table
mod_summary_card_server <- function(id, var, period = "month", n = NULL, type = "area", sparkline.enabled = T){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    card_data <- reactiveVal(get_summary_info(var, period, n))

    output$h <- renderText({
      d <- card_data()
      d3.format::d3.format(d$format_specifier)(d$this_period_val)
    })

    output$t <- renderUI({
      d <- card_data()
      trend_annotation(magnitude = d$trend_magnitude,
                       direction = d$trend_direction)
    })

    output$s <- renderText({
      d <- card_data()
      d$series_heading

    })

    output$c <- apexcharter::renderApexchart({

      d <- card_data()
      y_formatter = apexcharter::format_num(d$format_specifier)

      a <- apexcharter::apexchart() %>%
        ax_chart(
          type = type,
          toolbar = list(show = FALSE),
          sparkline = list(enabled = sparkline.enabled),
          animations = list(enabled = FALSE),
          stacked = FALSE) %>%
        apexcharter::ax_series(
          list(name = d$series_name,
               data = d$series_y)) %>%
        apexcharter::ax_xaxis(
          categories = d$x_categories)%>%
        apexcharter::ax_yaxis(
          labels = list(formatter = y_formatter)) %>%
        apexcharter::ax_tooltip(
          x = list(format = "MMM yyyy"),
          y = list(formatter = y_formatter)) %>%
        apexcharter::ax_plotOptions(
          bar = list(columnWidth = "50%")) %>%
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

mod_summary_card_app <- function(){
  ui <- tabler_page(
    mod_summary_card_ui(id = "i")
  )
  server <- function(input, output, session) {
    mod_summary_card_server("i", "n_matched")
  }
  shinyApp(ui, server)
}


#' @import data.table
get_summary_info <- function(var, period = "month", n = NULL){
  data <- aggregated[[period]]
  data <- data[order(date_bin_start),
               ][!is.na(date_bin_start), ]
  if (!is.null(n)) data <- data[(nrow(data) - n):nrow(data), ]

  this_period_val = data[nrow(data) - 1 , ..var][[1]]
  previous_period_val = data[nrow(data) - 2 , ..var][[1]]
  trend <- get_trend(this_period_val, previous_period_val)

  heading <- paste0(var_dictionary[[var]]$short_name)


  list(x_categories = data[, ..period, ][[1]],
       x_datetime = data[ , date_bin_start, ],
       series_y = data[, ..var][[1]],
       series_name = var_dictionary[[var]]$short_name,
       series_heading = heading,
       series_description = var_dictionary[[var]]$description,
       this_period_val = data[nrow(data) - 1 , ..var][[1]],
       trend_direction = trend$direction,
       trend_magnitude = trend$magnitude,
       format_specifier = specify_format(var))
}

get_trend <- function(this, previous){
  percentage_diff <- round((this - previous) / previous * 100)
  if (isTRUE(!is.na(percentage_diff)) & isTRUE(!is.null(percentage_diff))) {
    if (sign(percentage_diff) == 0) {
      trend_direction <- "none"
    } else if (sign(percentage_diff) == 1) {
      trend_direction <- "up"
    } else if (sign(percentage_diff) == -1) {
      trend_direction <- "down"
    }
  }
  list(magnitude = paste0(percentage_diff, "%"),
       direction = trend_direction)
}


specify_format <- function(var){
  format_specifier <- var_dictionary[[var]]$format
  if (is.null(format_specifier)) format_specifier <- ""
  format_specifier
}

## To be copied in the UI
# mod_summary_card_ui("summary_card_ui_1")

## To be copied in the server
# mod_summary_card_server("summary_card_ui_1")
