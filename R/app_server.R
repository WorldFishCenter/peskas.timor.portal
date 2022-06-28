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
  mod_summary_table_server(id = "revenue-table", vars = c("revenue", "recorded_revenue", "landing_revenue", "n_landings_per_boat"),  i18n_r = i18n_r)
  mod_var_descriptions_server(id = "revenue-info", vars = c("landing_revenue", "n_landings_per_boat", "n_boats", "revenue"), i18n_r = i18n_r)

  # Catch tab
  mod_highlight_card_server(id = "catch-card", var = "catch", period = "month", n = 25)
  mod_summary_card_server(id = "landing-catch-card", var = "landing_weight", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server(id = "landing-per-boat-catch-card", var = "n_landings_per_boat", period = "month", n = 13, i18n_r = i18n_r)
  mod_simple_summary_card_server(id = "n-boats-catch-card", var = "n_boats", period = "month", i18n_r = i18n_r)
  mod_summary_table_server(id = "catch-table", vars = c("catch", "recorded_catch", "landing_weight", "n_landings_per_boat"),  i18n_r = i18n_r)
  mod_var_descriptions_server(id = "catch-info", vars = c("landing_weight", "n_landings_per_boat", "n_boats", "catch"), i18n_r = i18n_r)

  # Composition tab
  taxa_colors <- viridisLite::viridis(length(pars$taxa$to_display)) %>% strtrim(width = 7)
  mod_taxa_bar_highlight_server("taxa-highlight", var = "catch", colors = taxa_colors)
  mapply(pars$taxa$to_display, taxa_colors, FUN = function(x, y){
    mod_summary_card_server(id = paste(x, "catch-card", sep = "-"), var = "catch", taxa = x, n = 25, colors = y)
  })
  mod_composition_table_server("taxa-table")
  mod_var_descriptions_server(id = "composition-info", vars = c("catch", "taxa"), i18n_r = i18n_r)

  # Tracks tab (dynamic map)
  leaflet_map_server_v1(id = "map", marker_radius = 7, scale_markers = TRUE, fill_marker_alpha = 0.6, legend_bins = 8)
  #leaflet_map_server(id = "map", marker_radius = 7, scale_markers = T, fill_marker_alpha = 0.6, legend_bins = 8, zoom = 8.5)

  mod_var_descriptions_server(id = "map-info", vars = c("pds_tracks_trips", "pds_tracks_cpe", "pds_tracks_rpe"), i18n_r = i18n_r)

  # Nutrition tab
  nutrients_colors <- c("#7ea0b7", "#376280", "#3d405b", "#969695", "#81b29a","#945183", "#a98600")
  #nutrients_colors <- viridisLite::viridis(length(pars$nutrients$to_display)) %>% strtrim(width = 7)
  mod_nutrients_highlight_card_server("nutrients-highlight", var = "nut_rdi", period = "month", n = 25, colors = nutrients_colors)
  mapply(pars$nutrients$to_display, nutrients_colors, FUN = function(x, y){
    mod_summary_card_server(id = paste(x, "nutrient-card", sep = "-"), var = "nut_rdi", nutrients = x, n = 25, colors = y)
  })
  mod_nutrient_treemap_server(id="nutrient-tree", var="nut_rdi", period = "month", n = NULL,
                                      type = "treemap", sparkline.enabled = F, y_formatter = apexcharter::format_num(""),
                                      colors = nutrients_colors)


  # About tab
  timor_about_server(id = "about-text", content = pars$about$text, i18n_r = i18n_r)
  mod_var_descriptions_server(id = "nutrients-info", vars = "nut_rdi", i18n_r = i18n_r)

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
