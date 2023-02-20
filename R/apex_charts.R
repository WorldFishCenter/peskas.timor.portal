apex_spider <- function(data = NULL, cols = NULL) {
  pg_dat_all <-
    data[, .("Price per Kg." = stats::median(price_kg)), by = "region"] %>%
    dplyr::mutate(period = "All data")

  pg_dat_latest <-
    data %>%
    dplyr::group_by(region) %>%
    dplyr::slice_tail(n = 2) %>%
    dplyr::summarise("Price per Kg." = stats::median(price_kg)) %>%
    dplyr::mutate(period = "Latest month")

  pg_dat <-
    dplyr::bind_rows(pg_dat_all, pg_dat_latest) %>%
    dplyr::mutate("Price per Kg." = round(`Price per Kg.`, 2))

  apexcharter::apexchart() %>%
    apexcharter::apex(
      data = pg_dat,
      type = "radar",
      mapping = apexcharter::aes(x = region, y = `Price per Kg.`, group = period)
    ) %>%
    apexcharter::ax_markers(size = 4) %>%
    apexcharter::ax_chart(
      toolbar = list(show = FALSE),
      animations = list(
        enabled = TRUE,
        speed = 800,
        animateGradually = list(enabled = TRUE),
        offsetX = 0,
        offsetY = 0
      )
    ) %>%
    apexcharter::ax_yaxis(
      labels = list(
        rotate = 0,
        datetimeUTC = FALSE,
        padding = 0,
        style = list(
          colors = "#000000"
        )
      ),
      axisBorder = list(
        show = FALSE
      )
    ) %>%
    apexcharter::ax_xaxis(
      type = "category",
      labels = list(
        rotate = 0,
        padding = 0,
        style = list(
          colors = "#000000"
        )
      ),
      axisBorder = list(
        show = FALSE
      )
    ) %>%
    apexcharter::ax_legend(
      position = "bottom",
      fontSize = 15
    ) %>%
    apexcharter::ax_colors(cols) %>%
    apexcharter::ax_grid(
      strokeDashArray = 4,
      padding = list(
        top = -20, right = -25, left = -25, bottom = -30
      )
    ) %>%
    # ax_title(
    #  text = "Catch price per Kg. (USD)",
    #  align = "center",
    #  style = list(
    #    fontWeight = "bold",
    #    fontFamily = "Helvetica Neue"
    #  )
    # ) %>%
    apexcharter::ax_responsive(list(
      options = list(
        yaxis = list(show = T)
      )
    ))
}

apex_donut <- function(data = NULL,
                       cols = NULL,
                       center_label = NULL,
                       show_total = F,
                       show_legend = F,
                       sparkline = T,
                       formatter = formatter) {
  apexcharter::apexchart() %>%
    apexcharter::apex(
      data = data,
      type = "donut",
      mapping = apexcharter::aes(x = data[1][[1]], y = data[2][[1]])
    ) %>%
    apexcharter::ax_chart(
      toolbar = list(show = FALSE),
      sparkline = list(enabled = sparkline),
      animations = list(
        enabled = TRUE,
        speed = 800,
        animateGradually = list(enabled = TRUE),
        offsetX = 0,
        offsetY = 0
      )
    ) %>%
    apexcharter::ax_legend(
      show = show_legend,
      position = "bottom",
      fontSize = 15
    ) %>%
    apexcharter::ax_colors(cols) %>%
    apexcharter::ax_plotOptions(
      pie = apexcharter::pie_opts(
        donut = list(labels = list(
          show = T,
          total = list(
            show = show_total,
            label = center_label,
            color = "#373d3f",
            formatter = formatter
          )
        ))
      )
    )
}

apex_radial <- function(data = NULL,
                        sparkline = T) {
  apexcharter::apexchart() %>%
    apexcharter::apex(
      data = data,
      type = "radial",
      mapping = apexcharter::aes(y = data[1][[1]], x = data[2][[1]])
    ) %>%
    apexcharter::ax_chart(
      toolbar = list(show = FALSE),
      sparkline = list(enabled = sparkline),
      animations = list(
        enabled = TRUE,
        speed = 1000,
        animateGradually = list(enabled = TRUE),
        offsetX = 0,
        offsetY = 0
      )
    ) %>%
    apexcharter::ax_grid(
      strokeDashArray = 4,
      padding = list(
        top = 0, right = 0, left = 0, bottom = 0
      )
    ) %>%
    apexcharter::ax_stroke(dashArray = 10, width = 3) %>%
    apexcharter::ax_plotOptions(
      radialBar =
        apexcharter::radialBar_opts(
          hollow = list(
            size = "80%"
          ),
          dataLabels = list(
            value = list(
              formatter = htmlwidgets::JS("function (x) {return x}")
            )
          )
        )
    )
}

apex_donut_ui <- function(id,
                          div_class = "col-md-3",
                          card_style = "min-height: 8rem",
                          apex_height = "21rem") {
  ns <- NS(id)

  tags$div(
    class = div_class,
    tags$div(
      class = "card",
      style = card_style,
      apexcharter::apexchartOutput(ns("chart"), height = apex_height)
    )
  )
}

apex_donut_server <- function(id = NULL,
                              data = NULL,
                              center_label = NULL,
                              show_total = T,
                              show_legend = F,
                              colors = NULL,
                              sparkline = T,
                              formatter = NULL,
                              ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$chart <- renderApexchart({
      apex_donut(
        data = data,
        cols = colors,
        center_label = center_label,
        show_total = show_total,
        show_legend = show_legend,
        sparkline = sparkline,
        formatter = formatter
      )
    })
  })
}

apex_radial_ui <- function(id, div_class = "col-md-3", card_style = "min-height: 8rem", apex_height = "21rem") {
  ns <- NS(id)

  tags$div(
    class = div_class,
    tags$div(
      class = "card",
      style = card_style,
      apexcharter::apexchartOutput(ns("chart"), height = apex_height)
    )
  )
}

apex_radial_server <- function(id = NULL,
                               data = NULL,
                               sparkline = T) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$chart <- renderApexchart({
      apex_radial(data = data, sparkline = sparkline)
    })
  })
}
