#' Plot series using apexcharter
#'
#' @param x_categories X axis categories
#' @param series Time series in list format
#' @param y_formatter Y axis formatter
#' @param type Plot type
#' @param sparkline Enable sparkiline
#' @param colors Plot colors
#' @param stacked Enable stacked plot
#'
#' @return An apexcharter timeseries
#' @export
#'
plot_timeseries <- function(x_categories, series, y_formatter = V8::JS("function(x) {return x}"), type = "bar", sparkline = F, colors = NULL, stacked = F) {
  if (is.null(colors)) colors <- c("#206bc4", "#aaaaaa")

  a <- apexcharter::apexchart() %>%
    apexcharter::ax_chart(
      type = type,
      toolbar = list(show = FALSE),
      sparkline = list(enabled = sparkline),
      animations = list(
        enabled = TRUE,
        speed = 800,
        animateGradually = list(enabled = TRUE)
      ),
      stacked = stacked,
      selection = list(enabled = FALSE),
      zoom = list(enabled = FALSE)
    ) %>%
    apexcharter::ax_dataLabels(
      enabled = F
    ) %>%
    apexcharter::ax_series2(series) %>%
    apexcharter::ax_xaxis(
      type = "datetime",
      categories = x_categories,
      labels = list(
        rotate = 0,
        datetimeUTC = FALSE,
        padding = 0
      ),
      axisBorder = list(
        show = FALSE
      )
    ) %>%
    apexcharter::ax_yaxis(
      labels = list(
        padding = 4,
        formatter = y_formatter
      )
    ) %>%
    apexcharter::ax_tooltip(
      x = list(format = "MMM yyyy"),
      y = list(formatter = y_formatter)
    ) %>%
    apexcharter::ax_plotOptions(
      bar = list(columnWidth = "50%")
    ) %>%
    apexcharter::ax_responsive(list(
      breakpoint = 576,
      options = list(
        yaxis = list(show = FALSE)
      )
    )) %>%
    apexcharter::ax_colors(colors) %>%
    ax_legend(
      position = "top",
      fontSize = 15
    )

  a
  if (type != "bar") {
    a <- a %>%
      apexcharter::ax_stroke(
        curve = "smooth",
        width = "1.5"
      )
  }

  if (isFALSE(sparkline)) {
    a <- a %>%
      apexcharter::ax_grid(
        strokeDashArray = 4,
        padding = list(
          top = -20, right = 0, left = -4, bottom = -4
        )
      )
  }

  a
}



#' Plot series using apexcharter
#'
#' @param x_categories X axis categories
#' @param series Time series in list format
#' @param y_formatter Y axis formatter
#' @param x_formatter X axis formatter
#' @param type Plot type
#' @param sparkline Enable sparkiline
#' @param colors Plot colors
#'
#' @return An apexcharter barplot
#' @export
#'
plot_horizontal_barplot <- function(x_categories, series, y_formatter, x_formatter, type = "bar", sparkline = F, colors = NULL) {
  if (is.null(colors)) colors <- c("#206bc4", "#aaaaaa")

  a <- apexcharter::apexchart() %>%
    apexcharter::ax_chart(
      type = type,
      toolbar = list(show = FALSE),
      sparkline = list(enabled = sparkline),
      animations = list(
        enabled = TRUE,
        speed = 800,
        animateGradually = list(enabled = TRUE)
      ),
      stacked = FALSE,
      selection = list(enabled = FALSE),
      zoom = list(enabled = FALSE)
    ) %>%
    apexcharter::ax_dataLabels(
      enabled = F
    ) %>%
    apexcharter::ax_series(series) %>%
    apexcharter::ax_xaxis(
      type = "categories",
      categories = x_categories,
      labels = list(
        rotate = 0,
        padding = 0,
        formatter = x_formatter,
        trim = FALSE
      ),
      axisBorder = list(
        show = FALSE
      )
    ) %>%
    apexcharter::ax_yaxis(
      labels = list(
        padding = 4,
        trim = FALSE,
        maxWidth = 1200
      )
    ) %>%
    apexcharter::ax_tooltip(
      x = list(format = y_formatter),
      y = list(formatter = x_formatter)
    ) %>%
    apexcharter::ax_plotOptions(
      bar = list(
        columnWidth = "50%",
        distributed = TRUE,
        horizontal = TRUE
      )
    ) %>%
    apexcharter::ax_responsive(list(
      breakpoint = 576,
      options = list(
        yaxis = list(show = FALSE)
      )
    )) %>%
    apexcharter::ax_colors(colors) %>%
    apexcharter::ax_legend(show = FALSE)

  if (type != "bar") {
    a <- a %>%
      apexcharter::ax_stroke(
        curve = "smooth",
        width = "1.5"
      )
  }

  if (isFALSE(sparkline)) {
    a <- a %>%
      apexcharter::ax_grid(
        strokeDashArray = 4,
        xaxis = list(lines = list(show = TRUE)),
        yaxis = list(lines = list(show = FALSE)),
        padding = list(
          top = -20, right = 0, left = 0, bottom = -4
        )
      )
  }

  a
}


plot_barplot <- function(x_categories, series, y_formatter, x_formatter, type = "bar", sparkline = F, horizontal = F, colors = NULL) {
  if (is.null(colors)) colors <- c("#206bc4", "#aaaaaa")

  a <- apexcharter::apexchart() %>%
    apexcharter::ax_chart(
      type = type,
      toolbar = list(show = FALSE),
      sparkline = list(enabled = sparkline),
      animations = list(
        enabled = TRUE,
        speed = 800,
        animateGradually = list(enabled = TRUE)
      ),
      stacked = FALSE,
      selection = list(enabled = FALSE),
      zoom = list(enabled = FALSE)
    ) %>%
    apexcharter::ax_dataLabels(
      enabled = F
    ) %>%
    apexcharter::ax_series(series) %>%
    apexcharter::ax_xaxis(
      type = "categories",
      categories = x_categories,
      labels = list(
        rotate = 0,
        padding = 0,
        formatter = x_formatter,
        trim = FALSE
      ),
      axisBorder = list(
        show = FALSE
      )
    ) %>%
    apexcharter::ax_yaxis(
      labels = list(
        padding = 4,
        trim = FALSE,
        maxWidth = 1200
      )
    ) %>%
    apexcharter::ax_tooltip(
      x = list(format = y_formatter),
      y = list(formatter = x_formatter)
    ) %>%
    apexcharter::ax_plotOptions(
      bar = list(
        columnWidth = "50%",
        distributed = TRUE,
        horizontal = horizontal
      )
    ) %>%
    apexcharter::ax_responsive(list(
      breakpoint = 576,
      options = list(
        yaxis = list(show = FALSE)
      )
    )) %>%
    apexcharter::ax_colors(colors) %>%
    apexcharter::ax_legend(show = FALSE)

  if (type != "bar") {
    a <- a %>%
      apexcharter::ax_stroke(
        curve = "smooth",
        width = "1.5"
      )
  }

  if (isFALSE(sparkline)) {
    a <- a %>%
      apexcharter::ax_grid(
        strokeDashArray = 4,
        xaxis = list(lines = list(show = TRUE)),
        yaxis = list(lines = list(show = FALSE)),
        padding = list(
          top = -20, right = 0, left = 0, bottom = -4
        )
      )
  }

  a
}

#' Plot series using apexcharter for more custom use
#' @param data Data to plot
#' @param type Plot type
#' @param sparkline Enable sparkiline
#' @param y_formatter Y axis formatter
#' @param plot_color Plot fill color
#' @param lab_color Plot lab color
#' @param mean Enable mean reference line
#'
#' @return An apexcharter timeseries
#' @export
#'
plot_timeseries_apex <- function(data = NULL,
                                 type = "area",
                                 sparkline = F,
                                 y_formatter = NULL,
                                 plot_color = "#206bc4",
                                 lab_color = "#000000",
                                 mean = FALSE) {
  a <-
    apexcharter::apex(
      data = data$data,
      serie_name = data$name,
      mapping = aes(x = date, y = round(value, 2)),
      type = "area"
    ) %>%
    apexcharter::ax_chart(
      sparkline = list(enabled = sparkline),
      toolbar = list(
        autoSelected = "pan",
        show = FALSE,
        animations = list(
          enabled = TRUE,
          speed = 800,
          animateGradually = list(enabled = TRUE)
        )
      )
    ) %>%
    apexcharter::ax_xaxis(
      type = "datetime",
      categories = data$x_categories,
      labels = list(
        rotate = 0,
        datetimeUTC = FALSE,
        padding = 0,
        style = list(
          colors = lab_color
        )
      ),
      axisBorder = list(
        show = FALSE
      )
    ) %>%
    apexcharter::ax_yaxis(
      labels = list(
        padding = 4,
        formatter = y_formatter,
        style = list(
          colors = lab_color
        )
      )
    ) %>%
    apexcharter::ax_responsive(list(
      options = list(
        yaxis = list(show = T)
      )
    )) %>%
    apexcharter::ax_legend(
      position = "top",
      fontSize = 15
    ) %>%
    apexcharter::ax_dataLabels(
      enabled = F
    ) %>%
    apexcharter::ax_legend(
      position = "top",
      fontSize = 15
    ) %>%
    apexcharter::ax_grid(
      strokeDashArray = 4,
      padding = list(
        top = -20, right = 0, left = -4, bottom = -4
      )
    ) %>%
    apexcharter::ax_colors(plot_color) %>%
    apexcharter::ax_grid(
      strokeDashArray = 4,
      padding = list(
        top = -20, right = 0, left = -4, bottom = -4
      )
    ) %>%
    apexcharter::ax_markers(size = 4,
                            colors = plot_color)

  if (isTRUE(mean)) {
    a %>%
      apexcharter::add_hline(value = mean(data$data$value, na.rm = T))
  } else {
    a
  }
}
