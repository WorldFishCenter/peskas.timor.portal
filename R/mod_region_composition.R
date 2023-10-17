#' mod_region_composition_ui UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_region_composition_ui <- function(id, heading = NULL, apex_height = "20rem", ...) {
  ns <- NS(id)

  # if (is.null(years)) {
  years <- seq(as.numeric(format(Sys.Date(), "%Y")), "2018")
  # }

  s <- selectInput(ns("y"),
    label = "",
    choices = years,
    selectize = FALSE,
    width = "auto"
  )

  s$children[[2]]$children[[1]] <-
    htmltools::tagAppendAttributes(s$children[[2]]$children[[1]],
      class = "form-select"
    )


  tagList(
    highlight_card(
      id = id,
      card_class = "col-12",
      heading = heading,
      top_right = s,
      in_body = tags$div(
        class = "mt-0",
        # apexcharter::apexchartOutput(ns("rc"), height = apex_height)
        uiOutput(ns("c"))
      ),
      ...
    )
  )
}

#' mod_region_composition Server Functions
#'
#' @noRd
mod_region_composition_server <- function(id,
                                          xvar,
                                          yvar,
                                          fillvar,
                                          legend_position,
                                          legend_align,
                                          legend_fontsize,
                                          col_length,
                                          y_formatter,
                                          i18n_r = reactive(list(t = function(x) x))) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    plot_data <- reactive({
      region_composition <-
        peskas.timor.portal::municipal_taxa %>%
        dplyr::select(region, date_bin_start, catch, grouped_taxa) %>%
        dplyr::mutate(year = data.table::year(date_bin_start)) %>%
        dplyr::filter(year %in% input$y) %>%
        dplyr::group_by(region, grouped_taxa) %>%
        dplyr::summarise(catch = sum(catch)) %>%
        dplyr::mutate(
          tot_catch = sum(catch),
        ) %>%
        dplyr::ungroup() %>%
        tidyr::complete(region, grouped_taxa) %>%
        dplyr::left_join(peskas.timor.portal::taxa_names, by = "grouped_taxa") %>%
        dplyr::mutate(grouped_taxa_names = factor(grouped_taxa_names,
          levels = peskas.timor.portal::taxa_names$grouped_taxa_names,
        )) %>%
        dplyr::select(region, catch, grouped_taxa_names) %>%
        dplyr::group_by(region) %>%
        dplyr::arrange(grouped_taxa_names) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(catch = round(catch, 2) / 1000)
    })

    output$c <- renderUI({
      data <- plot_data()
      data$grouped_taxa_names <- i18n_r()$t(as.character(data$grouped_taxa_names))

      x <- rlang::enquo(arg = xvar)
      y <- rlang::enquo(arg = yvar)
      group <- rlang::enquo(arg = fillvar)

      output$char <- apexcharter::renderApexchart({
        apex_bar_stacked(
          plot_data = data,
          xvar = x,
          yvar = y,
          fillvar = group,
          legend_position,
          legend_align,
          legend_fontsize,
          col_length,
          y_formatter
        )
      })
    })
    apexcharter::apexchartOutput(ns("char"), height = "20rem")
  })
}
