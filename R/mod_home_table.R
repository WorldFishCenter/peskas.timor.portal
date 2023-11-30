#' composition_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_table_react_ui <- function(id, ...) {
  ns <- NS(id)
  uiOutput(ns("o"))
}


#' home_table Server Functions
#'
#' @noRd
mod_home_table_server <- function(id, color_pal = NULL, i18n_r = reactive(list(t = function(x) x))) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    make_color_pal <- function(colors, bias = 1) {
      get_color <- grDevices::colorRamp(colors, bias = bias)
      function(x) grDevices::rgb(get_color(x), maxColorValue = 255)
    }

    good_color <- make_color_pal(color_pal, bias = 2)

    output$o <- renderUI({
      output$t <- reactable::renderReactable({
        tab <-
          peskas.timor.portal::municipal_aggregated %>%
          dplyr::group_by(region) %>%
          dplyr::summarise(
            landing_revenue = stats::median(landing_revenue),
            landing_weight = stats::median(landing_weight),
            n_landings_per_boat = stats::median(n_landings_per_boat),
            revenue = sum(revenue) / 1000000,
            catch = sum(catch) / 1000,
            price_kg = mean(price_kg)
          ) %>%
          dplyr::ungroup()

        tot_row <-
          tab %>%
          dplyr::summarise(
            region = "Total",
            landing_revenue = stats::median(landing_revenue),
            landing_weight = stats::median(landing_weight),
            n_landings_per_boat = stats::median(n_landings_per_boat),
            revenue = sum(revenue),
            catch = sum(catch),
            price_kg = mean(price_kg)
          )

        tab <-
          tab %>%
          # dplyr::bind_rows(tab, tot_row) %>%
          dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ round(., 2)))

        tbl <-
          reactable::reactable(
            tab,
            theme = reactablefmtr::fivethirtyeight(centered = TRUE),
            pagination = FALSE,
            compact = FALSE,
            borderless = FALSE,
            striped = FALSE,
            fullWidth = TRUE,
            sortable = TRUE,
            defaultSorted = "region",
            defaultColDef = reactable::colDef(
              align = "center",
              minWidth = 100
            ),
            columns = list(
              region = reactable::colDef(
                name = "Municipality",
                minWidth = 140,
                align = "center"
              ),
              landing_revenue = reactable::colDef(
                name = "Revenue per trip",
                style = function(value) {
                  normalized <- (value - min(tab$landing_revenue)) / (max(tab$landing_revenue) - min(tab$landing_revenue))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {paste0("$", value)}
              ),
              n_landings_per_boat = reactable::colDef(
                name = "Landings per boat",
                style = function(value) {
                  normalized <- (value - min(tab$n_landings_per_boat)) / (max(tab$n_landings_per_boat) - min(tab$n_landings_per_boat))
                  color <- good_color(normalized)
                  list(background = color)
                }
              ),
              landing_weight = reactable::colDef(
                name = "Catch per trip",
                style = function(value) {
                  normalized <- (value - min(tab$landing_weight)) / (max(tab$landing_weight) - min(tab$landing_weight))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {paste0(value, " kg")}
              ),
              revenue = reactable::colDef(
                name = "Total revenue",
                format = reactable::colFormat(separators = TRUE),
                style = function(value) {
                  normalized <- (value - min(tab$revenue)) / (max(tab$revenue) - min(tab$revenue))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {paste0("$", value, " M")}
              ),
              catch = reactable::colDef(
                name = "Total catch",
                format = reactable::colFormat(separators = TRUE),
                style = function(value) {
                  normalized <- (value - min(tab$catch)) / (max(tab$catch) - min(tab$catch))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {paste0(value, " t")}
              ),
              price_kg = reactable::colDef(
                name = "Price per kg",
                style = function(value) {
                  normalized <- (value - min(tab$price_kg)) / (max(tab$price_kg) - min(tab$price_kg))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {paste0("$", value)}
              )
            )
          )
        tbl
      })

      tagList(
        div(
          class = "title",
          h2(p(i18n_r()$t(pars$home$table$title), style = "color:#666a70")),
          p(i18n_r()$t(pars$home$table$caption), style = "color:#666a70")
        ),
        reactable::reactableOutput(ns("t"), width = "100%")
      )
    })
  })
}

## To be copied in the UI
# mod_home_table_ui("composition_table_1")

## To be copied in the server
# mod_home_table_server("composition_table_1")
