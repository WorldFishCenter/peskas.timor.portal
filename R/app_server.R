#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session){
  i18n_r <- mod_language_server("lang", session)
  # For translation made in the UI

  # Summary tab
  mod_summary_card_server(id = "revenue-summary-card", var = "revenue", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server(id = "catch-summary-card", var = "catch", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server(id = "landings-card", var = "n_landings", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server(id = "tracks-card", var = "n_tracks", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server(id = "matched-card", var = "n_matched", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server(id = "women-prop-summary-card", var = "prop_landings_woman", period = "month", n = 13, i18n_r = i18n_r)



  # Revenue tab
  mod_highlight_card_server(id = "revenue-card", var = "revenue", period = "month", n = 25)
  mod_summary_card_server(id = "landing-revenue-card", var = "landing_revenue", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server(id = "landing-per-boat-revenue-card", var = "n_landings_per_boat", period = "month", n = 13, i18n_r = i18n_r)
  mod_simple_summary_card_server(id = "n-boats-revenue-card", var = "n_boats", period = "month", i18n_r = i18n_r)
  mod_summary_table_server(id = "revenue-table", vars = c("revenue", "landing_revenue", "n_landings_per_boat", "n_boats"),  i18n_r = i18n_r)
  mod_var_descriptions_server(id = "revenue-info", vars = c("landing_revenue", "n_landings_per_boat", "n_boats", "revenue"), i18n_r = i18n_r)

  # Revenue tab
  mod_highlight_card_server(id = "catch-card", var = "catch", period = "month", n = 25)
  mod_summary_card_server(id = "landing-catch-card", var = "landing_weight", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server(id = "landing-per-boat-catch-card", var = "n_landings_per_boat", period = "month", n = 13, i18n_r = i18n_r)
  mod_simple_summary_card_server(id = "n-boats-catch-card", var = "n_boats", period = "month", i18n_r = i18n_r)
  mod_summary_table_server(id = "catch-table", vars = c("catch", "landing_weight", "n_landings_per_boat", "n_boats"),  i18n_r = i18n_r)
  mod_var_descriptions_server(id = "catch-info", vars = c("landing_weight", "n_landings_per_boat", "n_boats", "catch"), i18n_r = i18n_r)

  # Composition tab
  taxa_colors <- viridisLite::viridis(length(pars$taxa$to_display)) %>%
    strtrim(width = 7)
  mod_taxa_bar_highlight_server("taxa-highlight", var = "catch", colors = taxa_colors)
  mapply(pars$taxa$to_display, taxa_colors, FUN = function(x, y){
    mod_summary_card_server(id = paste(x, "catch-card", sep = "-"), var = "catch", taxa = x, n = 25, colors = y)
  })
  mod_composition_table_server("taxa-table")
  mod_var_descriptions_server(id = "composition-info", vars = c("catch", "taxa"), i18n_r = i18n_r)

  # Tracks tab
  mod_var_descriptions_server(id = "tracks-info", vars = c("pds_tracks"), i18n_r = i18n_r)

}

#' Dummy apex chart
#'
#' @return an htmlwidget
#' @import apexcharter
dummy_chart <- function(type = "bar", sparkline.enabled = TRUE){
  apexchart() %>%
    ax_chart(type = type,
             toolbar = list(show = FALSE),
             sparkline = list(enabled = sparkline.enabled ),
             animations = list(enabled = FALSE)) %>%
    ax_plotOptions(bar = list(columnWidth = "50%")) %>%
    ax_series(
      list(
        name = "Example",
        data = sample(900:1500, 24)
      )
    ) %>%
    ax_colors("#206bc4") %>%
    ax_stroke(width = 1.5)

}
