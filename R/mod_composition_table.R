#' composition_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_composition_table_ui <- function(id, ...) {
  ns <- NS(id)
  tagList(
    table_card(
      # As an html output so we can tweak the alignment reactively
      table = htmlOutput(ns("o")),
      # dropdown = s,
      footer = i18n$t(pars$composition$table$footer$text),
      ...
    )
  )
}

#' composition_table Server Functions
#'
#' @noRd
mod_composition_table_server <- function(id, var = "catch", i18n_r = reactive(list(t = function(x) x))) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns


    output$t <- renderUI({
      var_info <- get_var_info(var)

      multiplier <- var_info[[var]]$multiplier
      format <- var_info[[var]]$format
      x <- peskas.timor.portal::taxa_aggregated$year[year >= 2018]
      x <- x[, (var) := get(var) * multiplier]
      x <- x[, (var) := d3.format::d3_format(format)(get(var))]
      x <- x[grouped_taxa %in% peskas.timor.portal::pars$taxa$to_display]
      x <- x[, grouped_taxa := factor(grouped_taxa, peskas.timor.portal::pars$taxa$to_display)]
      x <- dcast(x, grouped_taxa ~ year, value.var = var)
      x <- merge(x[order(grouped_taxa)], peskas.timor.portal::taxa_names)
      x <- setcolorder(x, c("grouped_taxa_names", "grouped_taxa"))
      table <- setnames(x, old = c("grouped_taxa", "grouped_taxa_names"), new = c("code", "name"))
      table$name <- i18n_r()$t(table$name)
      alignment <- c("l", rep("r", ncol(table) - 1))
      alignment <- paste(alignment, collapse = "")
      output$table <- renderTable(table,
        spacing = "m", width = "100%",
        align = alignment,
        na = "\u2013",
        class = "table-responsive"
      )
      tableOutput(ns("table"))
    })
  })
}


mod_composition_table_react_server <- function(id, cols = NULL, var = "catch", i18n_r = reactive(list(t = function(x) x))) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    images <- c(
      "https://storage.googleapis.com/public-timor/SAR.svg",
      "https://storage.googleapis.com/public-timor/GAR.svg",
      "https://storage.googleapis.com/public-timor/TUN.svg",
      "https://storage.googleapis.com/public-timor/MAC.svg",
      "https://storage.googleapis.com/public-timor/FLYFI.svg",
      "https://storage.googleapis.com/public-timor/SNA.svg",
      "https://storage.googleapis.com/public-timor/MOO.svg",
      "https://storage.googleapis.com/public-timor/JAC.svg",
      "https://storage.googleapis.com/public-timor/FUS.svg",
      "https://storage.googleapis.com/public-timor/NEE.svg",
      "https://storage.googleapis.com/public-timor/SHM.svg",
      "https://storage.googleapis.com/public-timor/JOB.svg",
      "https://storage.googleapis.com/public-timor/OTHR.svg"
    )

    tab <-
      peskas.timor.portal::municipal_taxa %>%
      dplyr::select(date_bin_start, catch, grouped_taxa) %>%
      dplyr::mutate(year = data.table::year(date_bin_start)) %>%
      dplyr::group_by(year, grouped_taxa) %>%
      dplyr::summarise(catch = sum(catch)) %>%
      dplyr::ungroup() %>%
      tidyr::complete(grouped_taxa) %>%
      dplyr::left_join(peskas.timor.portal::taxa_names, by = "grouped_taxa") %>%
      dplyr::mutate(grouped_taxa_names = factor(grouped_taxa_names,
        levels = peskas.timor.portal::taxa_names$grouped_taxa_names,
      )) %>%
      dplyr::select(year, catch, grouped_taxa_names) %>%
      dplyr::arrange(grouped_taxa_names) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(catch = round(catch, 2) / 1000) %>%
      dplyr::filter(!is.na(year)) %>%
      tidyr::pivot_wider(names_from = year, values_from = catch) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(ts = list(c(`2018`, `2019`, `2020`, `2021`, `2022`, `2023`))) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(
        urls = images,
        dplyr::across(dplyr::where(is.numeric), ~ round(.x, 2))
      ) %>%
      dplyr::select(grouped_taxa_names, urls, dplyr::everything())

    output$o <- renderUI({
      tab$grouped_taxa_names <- i18n_r()$t(as.character(tab$grouped_taxa_names))
      output$t <- reactable::renderReactable({
        tab %>%
          reactable::reactable(
            theme = reactablefmtr::fivethirtyeight(centered = T, cell_padding = 0),
            pagination = FALSE,
            compact = FALSE,
            borderless = TRUE,
            striped = FALSE,
            fullWidth = TRUE,
            sortable = TRUE,
            height = 500,
            defaultColDef = reactable::colDef(
              align = "center"
            ),
            columns = list(
              grouped_taxa_names = reactable::colDef(
                name = "Taxa",
                minWidth = 100
              ),
              "2018" = reactable::colDef(
                maxWidth = 90,
                format = reactable::colFormat(separators = TRUE),
                style = reactablefmtr::color_scales(., colors = cols, opacity = 0.75),
                cell = JS("function(cellInfo) {return cellInfo.value + ' t'}")
              ),
              "2019" = reactable::colDef(
                maxWidth = 90,
                format = reactable::colFormat(separators = TRUE),
                style = reactablefmtr::color_scales(., colors = cols, opacity = 0.75),
                cell = htmlwidgets::JS("function(cellInfo) {return cellInfo.value + ' t'}")
              ),
              "2020" = reactable::colDef(
                maxWidth = 90,
                format = reactable::colFormat(separators = TRUE),
                style = reactablefmtr::color_scales(., colors = cols, opacity = 0.75),
                cell = htmlwidgets::JS("function(cellInfo) {return cellInfo.value + ' t'}")
              ),
              "2021" = reactable::colDef(
                maxWidth = 90,
                format = reactable::colFormat(separators = TRUE),
                style = reactablefmtr::color_scales(., colors = cols, opacity = 0.75),
                cell = htmlwidgets::JS("function(cellInfo) {return cellInfo.value + ' t'}")
              ),
              "2022" = reactable::colDef(
                maxWidth = 90,
                format = reactable::colFormat(separators = TRUE),
                style = reactablefmtr::color_scales(., colors = cols, opacity = 0.75),
                cell = htmlwidgets::JS("function(cellInfo) {return cellInfo.value + ' t'}")
              ),
              "2023" = reactable::colDef(
                maxWidth = 90,
                format = reactable::colFormat(separators = TRUE),
                style = reactablefmtr::color_scales(., colors = cols, opacity = 0.75),
                cell = htmlwidgets::JS("function(cellInfo) {return cellInfo.value + ' t'}")
              ),
              urls = reactable::colDef(
                name = "",
                minWidth = 150,
                footer = i18n_r()$t(pars$composition$table$footer$text),
                footerStyle = list(fontWeight = "lighter"),
                format = reactable::colFormat(separators = TRUE),
                cell = reactablefmtr::embed_img(
                  height = 60,
                  width = 95
                )
              ),
              ts = reactable::colDef(
                name = "Time Series",
                minWidth = 250,
                cell = reactablefmtr::react_sparkline(
                  .,
                  height = 80,
                  line_color = "#00939d",
                  line_width = 2,
                  statline = "mean",
                  statline_color = "#9d0a00",
                  statline_label_size = "0.9em",
                  area_opacity = 0.1,
                  show_area = TRUE,
                  tooltip_type = 1
                )
              )
            )
          )
      })
      reactable::reactableOutput(ns("t"), width = "100%")
    })
  })
}

## To be copied in the UI
# mod_composition_table_ui("composition_table_1")

## To be copied in the server
# mod_composition_table_server("composition_table_1")
