#' summary_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_summary_card_ui <- function(id, div_class = "col-md-3", card_style = "min-height: 8rem") {
  ns <- NS(id)

  tags$div(
    class = div_class,
    tags$div(
      class = "card",
      style = card_style,
      summary_card_content_placeholder(ns("placeholder")),
      uiOutput(ns("o"))
    )
  )
}

#' summary_card Server Functions
#'
#' @noRd
#' @import data.table
mod_summary_card_server <- function(id, var, period = "month", n = NULL,
                                    type = "area",
                                    sparkline.enabled = T,
                                    apex_height = "4rem",
                                    i18n_r = reactive(list(t = function(x) x)),
                                    colors = NULL,
                                    ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Add debouncing for region input
    muni_debounced <- reactive({
      input$muni
    }) %>% debounce(300) # 300ms delay for summary cards

    data <- reactive(get_series_info(var, period, n, region = muni_debounced(), ...))

    output$o <- renderUI({
      d <- data()

      # We use the format of the first series overall
      y_formatter <- apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)
      series <- lapply(d$series, function(x) {
        list(
          name = x$series_name,
          data = x$series_value * d$series[[1]]$series_multiplier
        )
      })

      output$chart <- renderApexchart({
        plot_timeseries(
          x_categories = d$x_datetime,
          series = series,
          y_formatter = y_formatter,
          type = type,
          sparkline = sparkline.enabled,
          colors = colors
        )
      })

      shinyjs::hideElement("placeholder")

      summary_card_content(
        id = id,
        subheader = i18n_r()$t(d$series[[1]]$series_heading),
        heading = d3.format::d3.format(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)(d$series[[1]]$last_period_val * d$series[[1]]$series_multiplier),
        annotation = trend_annotation_summary_card(
          magnitude = d$series[[1]]$trend_magnitude,
          direction = d$series[[1]]$trend_direction
        ),
        top_right_element = d$series[[1]]$last_period,
        off_body = tags$div(
          class = "mt-0",
          apexchartOutput(ns("chart"), height = apex_height)
        )
      )
    })
  })
}


mod_summary_card_app <- function(options = list()) {
  i18n <- shiny.i18n::Translator$new(
    translation_json_path = system.file("translation.json", package = "peskas.timor.portal")
  )

  ui <- tabler_page(
    shiny.i18n::usei18n(i18n),
    shinyjs::useShinyjs(),
    mun_select("peppe"),
    mod_summary_card_ui(id = "peppe"),
    mod_summary_card_ui(id = "pino")
  )
  server <- function(input, output, session) {
    i18n_r <- reactive({
      selected <- input$language
      if (length(selected) > 0 && selected %in% i18n$get_languages()) {
        i18n$set_translation_language(selected)
      }
      i18n
    })

    mod_summary_card_server("peppe", "n_landings_per_boat", n = 13, apex_height = "100px", i18n_r = i18n_r)
    mod_summary_card_server("pino", "catch", n = 13, apex_height = "100px", i18n_r = i18n_r)
  }
  shinyApp(ui, server, options = options)
}

# mod_summary_card_app()

summary_card_content <- function(id = "",
                                 heading = "Card heading",
                                 subheader = "Card subheader",
                                 annotation = NULL,
                                 top_right_element = NULL,
                                 in_body = NULL,
                                 off_body = NULL,
                                 card_class = "") {
  tagList(
    tags$div(
      class = "card-body pb-0",
      tags$div(
        class = "d-flex align-items-center",
        tags$div(
          class = "font-weight-medium",
          subheader
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
          annotation
        )
      ),
      tags$div(
        class = "in-body",
        in_body
      )
    ),
    tags$div(
      class = "off-body",
      off_body
    )
  )
}


summary_card_content_placeholder <- function(id = "") {
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

card_dropdown <- function() {
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

unit_annotation <- function(unit = NULL) {
  div(
    class = "text-muted mb-1",
    unit
  )
}

trend_annotation_summary_card <- function(magnitude = "0%", direction = c("none", "up", "down")) {
  icon <- trend_icon(direction, style = "trend")
  colour_class <- trend_color(direction)$text

  tags$span(
    class = paste(colour_class, "ms-2 d-inline-flex align-items-center font-weight-medium lh-1"),
    magnitude,
    icon
  )
}

trend_icon <- function(direction = c("none", "up", "down"), style = c("trend", "arrow")) {
  if (style == "trend") {
    switch(direction[1],
      "none" = icon_trend_none(),
      "up" = icon_trend_up(),
      "down" = icon_trend_down(),
      NULL
    )
  } else {
    switch(direction[1],
      "none" = icon_trend_none(),
      "up" = icon_arrow_up(),
      "down" = icon_arrow_down(),
      NULL
    )
  }
}

trend_color <- function(direction = c("none", "up", "down")) {
  list(
    text = switch(direction[1],
      "none" = "text-yellow",
      "up" = "text-green",
      "down" = "text-red",
      "text-muted"
    ),
    background = switch(direction[1],
      "none" = "bg-yellow-lt",
      "up" = "bg-green-lt",
      "down" = "bg-red-lt",
      "bg-secondary-lt"
    )
  )
}


#####

mod_summary_card_ui2 <- function(id, div_class = "col-md-3", card_style = "min-height: 8rem") {
  ns <- NS(id)

  tags$div(
    class = div_class,
    tags$div(
      class = "card",
      style = card_style,
      summary_card_content_placeholder(ns("placeholder")),
      uiOutput(ns("oii"))
    )
  )
}

mod_summary_card_ui3 <- function(id, div_class = "col-md-3", card_style = "min-height: 8rem") {
  ns <- NS(id)

  tags$div(
    class = div_class,
    tags$div(
      class = "card",
      style = card_style,
      summary_card_content_placeholder(ns("placeholder2")),
      uiOutput(outputId = ns("oiii"))
    )
  )
}


mod_summary_card_server2 <- function(id, var, period = "month", n = NULL,
                                     type = "area",
                                     sparkline.enabled = T,
                                     apex_height = "4rem",
                                     i18n_r = reactive(list(t = function(x) x)),
                                     colors = NULL,
                                     ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    data <- reactive(get_series_info(var, period, n, region = input$muni, ...))

    output$oii <- renderUI({
      d <- data()

      # We use the format of the first series overall
      y_formatter <- apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)
      series <- lapply(d$series, function(x) {
        list(
          name = x$series_name,
          data = x$series_value * d$series[[1]]$series_multiplier
        )
      })

      output$chart <- renderApexchart({
        plot_timeseries(
          x_categories = d$x_datetime,
          series = series,
          y_formatter = y_formatter,
          type = type,
          sparkline = sparkline.enabled,
          colors = colors
        )
      })

      shinyjs::hideElement("placeholder")

      summary_card_content(
        id = id,
        subheader = i18n_r()$t(d$series[[1]]$series_heading),
        heading = d3.format::d3.format(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)(d$series[[1]]$last_period_val * d$series[[1]]$series_multiplier),
        annotation = trend_annotation_summary_card(
          magnitude = d$series[[1]]$trend_magnitude,
          direction = d$series[[1]]$trend_direction
        ),
        top_right_element = d$series[[1]]$last_period,
        off_body = tags$div(
          class = "mt-0",
          apexchartOutput(ns("chart"), height = apex_height)
        )
      )
    })
  })
}

mod_summary_card_server3 <- function(id, var, period = "month", n = NULL,
                                     type = "area",
                                     sparkline.enabled = T,
                                     apex_height = "4rem",
                                     i18n_r = reactive(list(t = function(x) x)),
                                     colors = NULL,
                                     ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    data <- reactive(get_series_info(var, period, n, region = input$muni, ...))

    output$oiii <- renderUI({
      d <- data()

      # We use the format of the first series overall
      y_formatter <- apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)
      series <- lapply(d$series, function(x) {
        list(
          name = x$series_name,
          data = x$series_value * d$series[[1]]$series_multiplier
        )
      })

      output$chart2 <- renderApexchart({
        plot_timeseries(
          x_categories = d$x_datetime,
          series = series,
          y_formatter = y_formatter,
          type = type,
          sparkline = sparkline.enabled,
          colors = colors
        )
      })

      shinyjs::hideElement("placeholder2")

      summary_card_content(
        id = id,
        subheader = i18n_r()$t(d$series[[1]]$series_heading),
        heading = d3.format::d3.format(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)(d$series[[1]]$last_period_val * d$series[[1]]$series_multiplier),
        annotation = trend_annotation_summary_card(
          magnitude = d$series[[1]]$trend_magnitude,
          direction = d$series[[1]]$trend_direction
        ),
        top_right_element = d$series[[1]]$last_period,
        off_body = tags$div(
          class = "mt-0",
          apexchartOutput(ns("chart2"), height = apex_height)
        )
      )
    })
  })
}
