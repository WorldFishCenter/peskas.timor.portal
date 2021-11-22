

#' Plot series using apexcharter
#'
plot_timeseries <- function(x_categories, series, y_formatter = V8::JS("function(x) {return x}"), type = "bar", sparkline = F, colors = NULL){

  if (is.null(colors)) colors <- c("#206bc4", "#aaaaaa")

  a <- apexcharter::apexchart() %>%
    apexcharter::ax_chart(
      type = type,
      toolbar = list(show = FALSE),
      sparkline = list(enabled = sparkline),
      animations = list(
        enabled = TRUE,
        speed = 800,
        animateGradually = list(enabled = TRUE)),
      stacked = FALSE,
      selection = list(enabled = FALSE),
      zoom = list(enabled = FALSE)) %>%
    apexcharter::ax_dataLabels(
      enabled = F) %>%
    apexcharter::ax_series(series) %>%
    apexcharter::ax_xaxis(
      type = "datetime",
      categories = x_categories,
      labels =  list(
        rotate = 0,
        datetimeUTC = FALSE,
        padding = 0),
      axisBorder = list(
        show = FALSE)) %>%
    apexcharter::ax_yaxis(
      labels = list(
        padding = 4,
        formatter = y_formatter)) %>%
    apexcharter::ax_tooltip(
      x = list(format = "MMM yyyy"),
      y = list(formatter = y_formatter)) %>%
    apexcharter::ax_plotOptions(
      bar = list(columnWidth = "50%")) %>%
    apexcharter::ax_responsive(list(
      breakpoint = 576,
      options = list(
        yaxis = list(show = FALSE)))) %>%
    apexcharter::ax_colors(colors)

  if (type != "bar") {
    a <- a %>%
      apexcharter::ax_stroke(curve = "smooth",
                             width = "1.5")
  }

  if (isFALSE(sparkline)) {
    a <- a %>%
      apexcharter::ax_grid(
        strokeDashArray = 4,
        padding = list(
          top = -20, right = 0, left = -4, bottom = -4))
  }

  a
}


  #' Plot series using apexcharter
  #'
plot_horizontal_barplot <- function(x_categories, series, y_formatter, x_formatter, type = "bar", sparkline = F, colors = NULL){

  if (is.null(colors)) colors <- c("#206bc4", "#aaaaaa")

  a <- apexcharter::apexchart() %>%
    apexcharter::ax_chart(
      type = type,
      toolbar = list(show = FALSE),
      sparkline = list(enabled = sparkline),
      animations = list(
        enabled = TRUE,
        speed = 800,
        animateGradually = list(enabled = TRUE)),
      stacked = FALSE,
      selection = list(enabled = FALSE),
      zoom = list(enabled = FALSE)) %>%
    apexcharter::ax_dataLabels(
      enabled = F) %>%
    apexcharter::ax_series(series) %>%
    apexcharter::ax_xaxis(
      type = "categories",
      categories = x_categories,
      labels =  list(
        rotate = 0,
        padding = 0,
        formatter = x_formatter,
        trim = FALSE),
      axisBorder = list(
        show = FALSE)) %>%
    apexcharter::ax_yaxis(
      labels = list(
        padding = 4,
        trim = FALSE,
        maxWidth = 1200)) %>%
    apexcharter::ax_tooltip(
      x = list(format = y_formatter),
      y = list(formatter = x_formatter)) %>%
    apexcharter::ax_plotOptions(
      bar = list(columnWidth = "50%",
                 distributed = TRUE,
                 horizontal = TRUE)) %>%
    apexcharter::ax_responsive(list(
      breakpoint = 576,
      options = list(
        yaxis = list(show = FALSE)))) %>%
    apexcharter::ax_colors(colors) %>%
    apexcharter::ax_legend(show = FALSE)

  if (type != "bar") {
    a <- a %>%
      apexcharter::ax_stroke(curve = "smooth",
                             width = "1.5")
  }

  if (isFALSE(sparkline)) {
    a <- a %>%
      apexcharter::ax_grid(
        strokeDashArray = 4,
        xaxis = list(lines = list(show = TRUE)),
        yaxis = list(lines = list(show = FALSE)),
        padding = list(
          top = -20, right = 0, left = 0, bottom = -4))
  }

  a
}

