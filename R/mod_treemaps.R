#' treemap_card UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_nutrient_treemap_ui <- function(id, heading = NULL, subheading = NULL, apex_height = "21rem", ...) {
  ns <- NS(id)
  tagList(
    highlight_card_narrow(
      id = id,
      heading = heading,
      subheading = subheading,
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
                                        label_formatter = NULL,
                                        ...) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    data <- peskas.timor.portal::summary_data$nutrients_per_catch
    data <- data[match(c(
      "Protein", "Zinc", "Omega-3",
      "Calcium", "Vitamin A", "Iron"
    ), data$nutrient_names), ]

    output$t <- apexcharter::renderApexchart({
      y_formatter <- apexcharter::format_num(",.2r", suffix = " individuals")

      apexcharter::apexchart() %>%
        apex(
          data = data,
          type = "treemap",
          mapping = aes(x = nutrient_names, y = nut_rdi, fill = nutrient_names)
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
        apexcharter::ax_colors(colors) %>%
        apexcharter::ax_dataLabels(
          enabled = TRUE,
          formatter = label_formatter
        )
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
