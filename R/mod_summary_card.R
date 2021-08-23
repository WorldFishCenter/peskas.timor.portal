#' summary_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_summary_card_ui <- function(id, div_class = "col-md-3"){
  ns <- NS(id)

  tags$div(
    class = div_class,
    tags$div(
      class = "card",
      summary_card_content_placeholder(ns("placeholder")),
      uiOutput(ns("o"))
    ),

  )
}

#' summary_card Server Functions
#'
#' @noRd
#' @import data.table
mod_summary_card_server <- function(id, var, period = "month", n = NULL, type = "area", sparkline.enabled = T, apex_height = "4rem"){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    data <- reactive(get_series_info(var, period, n))

    output$o <- renderUI({
      d <- data()

      # We use the format of the first series overall
      y_formatter = apexcharter::format_num(d$series[[1]]$series_format)
      series <- lapply(d$series, function(x) {
        list(
          name = x$series_name,
          data = x$series_value
        )})

      output$chart  <- renderApexchart({
        plot_timeseries(
          x_categories = d$x_datetime,
          series = series[[1]],
          y_formatter = y_formatter,
          type = type,
          sparkline = sparkline.enabled)
      })

      shinyjs::hideElement("placeholder")

      summary_card_content(
        id = id,
        subheader = d$series[[1]]$series_heading,
        heading = d3.format::d3.format(d$series[[1]]$series_format)(d$series[[1]]$last_period_val),
        annotation = trend_annotation(magnitude = d$series[[1]]$trend_magnitude,
                                      direction = d$series[[1]]$trend_direction),
        off_body = tags$div(
          class = "mt-0",
          apexchartOutput(ns("chart"), height = apex_height)))
    })
  })
}

mod_summary_card_app <- function(){
  ui <- tabler_page(
    mod_summary_card_ui(id = "i")
  )
  server <- function(input, output, session) {
    mod_summary_card_server("i", "n_matched", n = 13, apex_height = "100px")
  }
  shinyApp(ui, server)
}

summary_card_content <- function(id = "",
                         heading = "Card heading",
                         subheader = "Card subheader",
                         annotation = NULL,
                         top_right_element = NULL,
                         in_body = NULL,
                         off_body = NULL,
                         card_class = ""){
    tagList(
      tags$div(
        class = "card-body pb-0",
        tags$div(
          class = "d-flex align-items-center",
          tags$div(
            class = "subheader",
            subheader
          ),
          tags$div(
            class = "ms-auto lh-1",
            top_right_element
          )
        ),
        tags$div(
          class = "d-flex align-items-baseline",
          tags$div(
            class = "h1 mb-0",
            heading
          ),
          tags$div(
            class = "me-auto",
            annotation
          )
        ),
        tags$div(
          class = "in-body",
          in_body
        )
      ),
      tags$div(
        class = 'off-body',
        off_body
      )
    )
}


summary_card_content_placeholder <- function(id = ""){
  tags$div(
    id = id,
    class = "card-body",
    tags$div(
      class = "skeleton-heading"
    ),
    tags$div(
      class = "skeleton-line"
    ),
    tags$div(
      class = "skeleton-line"
    ),
    tags$div(
      class = "skeleton-line"
    ),
  )
}

card_dropdown <- function(){
  tags$div(
    class = "dropdown",
    tags$a(
      class = "dropdown-toggle text-muted",
      href = "#",
      `data-bs-toggle` = "dropdown",
      `aria-haspopup` = "true",
      `aria-expanded` = "false",
      "Last 7 days"
    ),
    tags$div(
      class = "dropdown-menu dropdown-menu-end",
      style = NA,
      tags$a(
        class = "dropdown-item active",
        href = "#",
        "Last 7 days"
      ),
      tags$a(
        class = "dropdown-item",
        href = "#",
        "Last 30 days"
      ),
      tags$a(
        class = "dropdown-item",
        href = "#",
        "Last 3 months"
      )
    )
  )
}

unit_annotation <- function(unit = NULL){
  div(
    class = "text-muted mb-1",
    unit
  )
}

trend_annotation <- function(magnitude = "0%", direction = c("none", "up","down")){

  icon <- switch(
    direction[1],
    "none" = icon_trend_none(),
    "up" = icon_trend_up(),
    "down" = icon_trend_down(),
    NULL
  )

  colour_class <- switch(
    direction[1],
    "none" = "text-yellow",
    "up" = "text-green",
    "down" = "text-red",
    "text-muted"
  )

  tags$span(
    class = paste(colour_class,"ms-2 d-inline-flex align-items-center lh-1"),
    magnitude,
    icon
  )
}
