#' highlight_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_nutrients_highlight_card_ui <- function(id, heading = NULL, apex_height = "20rem", ...) {
  ns <- NS(id)
  tagList(
    highlight_card(
      id = id,
      heading = heading,
      in_body = tags$div(
        class = "mt-0",
        apexcharter::apexchartOutput(ns("n"), height = apex_height)
      ),
      ...
    )
  )
}

#' highlight_card Server Functions
#'
#' @noRd
#'
mod_nutrients_highlight_card_server <- function(id, var, period = "month", n = NULL,
                                                type = "bar",
                                                sparkline.enabled = F,
                                                y_formatter = apexcharter::format_num(""),
                                                colors,
                                                ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    d <- get_series_info(var, period, n, nutrients = "zinc")

    data <- peskas.timor.portal::nutrients_aggregated$month
    data <- data[, c(1, 2, 4)]
    nutrient_names <- c(
      protein = "Protein", zinc = "Zinc", vitaminA = "Vitamin A",
      calcium = "Calcium", omega3 = "Omega-3", iron = "Iron"
    )

    data$nutrient_names <- as.character(nutrient_names[data$nutrient])

    l <- list()
    for (i in data$nutrient_names) {
      x <- as.data.frame(subset(data, nutrient_names == i))
      x <- x[(nrow(x) - n):(nrow(x)), ]
      lis <- list(
        name = unique(x$nutrient_names),
        data = x$nut_rdi * d$series[[1]]$series_multiplier
      )
      l[[i]] <- lis
    }

    output$n <- apexcharter::renderApexchart({
      y_formatter <- apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)
      series <- list(
        l$Protein, l$Zinc, l$`Vitamin A`, l$Calcium, l$`Omega-3`, l$Iron
      )

      plot_timeseries(
        x_categories = d$x_datetime,
        series = series,
        y_formatter = y_formatter,
        type = "bar",
        sparkline = F,
        stacked = T,
        colors
      )
    })
  })
}
