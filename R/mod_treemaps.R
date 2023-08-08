#' treemap_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_nutrient_treemap_ui <- function(id, heading = NULL, apex_height = "21rem", ...) {
  ns <- NS(id)
  tagList(
    highlight_card_narrow(
      id = id,
      heading = heading,
      in_body = tags$div(
        class = "mt-0",
        apexcharter::apexchartOutput(ns("t"), height = apex_height)
      ),
      ...
    )
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
    data$rdi_coeff <- c(
      pars$nutrients$nutrients$calcium$conversion_fact,
      pars$nutrients$nutrients$iron$conversion_fact,
      pars$nutrients$nutrients$omega3$conversion_fact,
      pars$nutrients$nutrients$protein$conversion_fact,
      pars$nutrients$nutrients$selenium$conversion_fact,
      pars$nutrients$nutrients$vitaminA$conversion_fact,
      pars$nutrients$nutrients$zinc$conversion_fact
    )
    data$people <- round(data$nut_supply / data$rdi_coeff, 2)
    data <- data[match(c(
      "selenium", "protein", "omega3",
      "calcium", "zinc", "iron", "vitaminA"
    ), data$nutrient), ]

    output$t <- apexcharter::renderApexchart({
      y_formatter <- apexcharter::format_num(",.2r", suffix = " individuals")

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
            animateGradually = list(enabled = TRUE),
            offsetX = 0,
            offsetY = 0
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

mod_normalized_treemap_ui <- function(id, heading = NULL, subheading = NULL, apex_height = "28rem", ...) {
  ns <- NS(id)
  tagList(
    highlight_card_narrow(
      id = id,
      heading = heading,
      subheading = subheading,
      in_body = tags$div(
        class = "mt-0",
        apexcharter::apexchartOutput(ns("n"), height = apex_height)
      ),
      ...
    )
  )
}

mod_normalized_treemap_server <- function(id,
                                          data = NULL,
                                          type = NULL,
                                          sparkline.enabled = F,
                                          y_formatter = NULL,
                                          label_formatter = NULL,
                                          colors,
                                          ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$n <- apexcharter::renderApexchart({
      apex_treemap(series = data, colors, legend_size = 15, y_formatter = y_formatter, label_formatter = label_formatter)
    })
  })
}
