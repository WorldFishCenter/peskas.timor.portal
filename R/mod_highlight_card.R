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
                           top_right = list()) {
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
          tagList(top_right)
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
                                  subheading = NULL,
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
          ),
          p(subheading)
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


mun_select <- function(id, header = NULL) {
  ns <- NS(id)
  regions <- list("Municipality" = sort(unique(peskas.timor.portal::municipal_aggregated$region)))

  selectInput(
    inputId = ns("muni"),
    label = tags$div(style = c("font-weight: bolder"), header),
    choices = c("National", regions),
    width = "20%"
  )
}
mod_highlight_mun_ui <- function(id, heading = NULL, apex_height = "20rem", ...) {
  ns <- NS(id)
  tagList(
    highlight_card(
      id = id,
      heading = heading,
      in_body = tags$div(
        class = "mt-0",
        apexcharter::apexchartOutput(ns("brush_1"), height = "260px"),
        apexcharter::apexchartOutput(ns("brush_2"), height = "130px")
      ),
      ...
    )
  )
}

mod_highlight_mun_server <- function(id,
                                     var,
                                     period = "month",
                                     sparkline.enabled = F,
                                     ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Add debouncing to prevent excessive reactive updates
    muni_debounced <- reactive({
      input$muni
    }) %>% debounce(500)  # 500ms delay

    dat <- reactive({
      d <- get_series_info(var, period, region = muni_debounced())

      list(
        data = data.frame(
          date = d$x_datetime,
          value = d$series[[1]]$series_value * d$series[[1]]$series_multiplier,
          x_categories = d$x_categories
        ),
        name = d$series[[1]]$series_name,
        format = d$series[[1]]$series_format,
        suffix = d$series[[1]]$series_suffix
      )
    })


    output$brush_1 <- apexcharter::renderApexchart({
      y_formatter <- apexcharter::format_num(format = dat()$format, suffix = dat()$suffix)
      plot_timeseries_apex(data = dat(), y_formatter = y_formatter, mean = F) %>%
        apexcharter::ax_tooltip(
          x = list(format = "MMM yyyy"),
          y = list(formatter = y_formatter)
        )
    })

    output$brush_2 <- renderApexchart({
      y_formatter <- apexcharter::format_num(format = dat()$format, suffix = dat()$suffix)
      plot_timeseries_apex(data = dat(), y_formatter = y_formatter) %>%
        apexcharter::ax_tooltip(
          enabled = FALSE
        ) %>%
        apexcharter::set_input_selection(
          inputId = "brush",
          fill_color = "#2e5031",
          type = "x",
          xmin = format_date(dat()$data$date[1]),
          xmax = format_date(dat()$data$date[nrow(dat()$data)])
        )
    })

    observeEvent(input$brush, {
      apexcharter::apexchartProxy("brush_1") %>%
        apexcharter::ax_proxy_options(list(
          xaxis = list(
            min = as.numeric(input$brush$x$min) * 1000,
            max = as.numeric(input$brush$x$max) * 1000
          )
        ))
    })
  })
}

# mod_highlight_mun_app()
