#' treemap_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_nutrient_treemap_ui <- function(id, heading = NULL,
                                    div_class = "col-md-3",
                                    card_style = "min-height: 15rem",
                                    apex_height = "20rem", ...) {
  ns <- NS(id)
  tags$div(
    class = div_class,
    tags$div(
      class = "card",
      style = card_style,
      apexcharter::apexchartOutput(ns("t"), height = apex_height)
    ),
    ...
  )
}

#' treemap_card Server Functions
#'
#' @noRd
#'
mod_nutrient_treemap_server <- function(id, var, period = "month", n = NULL,
                                                type = NULL,
                                                sparkline.enabled = F,
                                                y_formatter = apexcharter::format_num(""),
                                                colors,
                                                ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    d <- get_series_info(var, period, n, nutrients = "selenium")

    data <- peskas.timor.portal::nutrients_aggregated$year
    data_agg <- peskas.timor.portal::aggregated$year
    data <- data[, c(2, 3)]
    data$nut_rdi <- (data$nut_supply / sum(data_agg$n_landings, na.rm = TRUE))
    data <- aggregate(nut_supply ~ nutrient, data = data, FUN = mean)
    nutrient_names <- c(
      selenium = "Selenium", zinc = "Zinc", protein = "Protein",
      omega3 = "Omega-3", calcium = "Calcium", iron = "Iron", vitaminA = "Vitamin A"
    )
    data$nutrient_names <- as.character(nutrient_names[data$nutrient])
    data$nut_supply <- data$nut_supply / 1000
    data$rdi_coeff <- c(1, 0.018, 1.1, 46, 0.000055, 0.0007, 0.008)
    data$people <- round(data$nut_supply / data$rdi_coeff, 2)

    output$t <- apexcharter::renderApexchart({
      y_formatter <- apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix)

      apexcharter::apexchart() %>%
        apex(
          data = data,
          type = type,
          mapping = aes(x = nutrient_names, y = people, fill = nutrient_names)
        ) %>%
        apexcharter::ax_chart(
          toolbar = list(show = FALSE),
          animations = list(
            enabled = TRUE,
            speed = 800,
            animateGradually = list(enabled = TRUE)
          )
        ) %>%
        apexcharter::ax_yaxis(
          labels = list(
            padding = 4,
            formatter = y_formatter
          )
        ) %>%
        ax_colors(colors)
    })
  })
}
