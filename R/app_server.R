#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  i18n_r <- mod_language_server("lang", session)

  habitat_palette <- c("#440154", "#30678D", "#35B778", "#FDE725", "#FCA35D", "#D32F2F", "#67001F")
  habitat_colors <- habitat_palette %>% strtrim(width = 7)


  # Home
  mod_home_table_server(id = "home_table", color_pal = c("#ffffff", "#f2fbd2", "#c9ecb4", "#93d3ab", "#35b0ab"), i18n_r = i18n_r)
  apex_donut_server(
    id = "donut_trips",
    data = peskas.timor.portal::summary_data$n_surveys,
    center_label = "Submitted surveys",
    cols = c("#d7eaf3", "#77b5d9", "#14397d"),
    sparkline = F,
    show_total = T,
    tooltip_formatter = V8::JS("function(x) {return (x).toLocaleString('en-US')}"),
    total_formatter = V8::JS("function (x) {return (x.globals.seriesTotals.reduce((a, b) => {return a + b}, 0)).toLocaleString('en-US')}")
  )

  apex_donut_server(
    id = "donut_revenue",
    data = peskas.timor.portal::summary_data$estimated_revenue,
    center_label = "Estimated revenue",
    cols = c("#d7eaf3", "#77b5d9", "#14397d"),
    sparkline = F,
    show_total = T,
    tooltip_formatter = V8::JS("function(x) {return '$' + (x / 1000000).toFixed(2) + ' M'}"),
    total_formatter = V8::JS("function (x) {return '$' + (x.globals.seriesTotals.reduce((a, b) => {return a + b}, 0) / 1000000).toFixed(2) + ' M'}")
  )

  apex_donut_server(
    id = "donut_fish",
    data = peskas.timor.portal::summary_data$estimated_tons,
    center_label = "Estimated catch",
    cols = viridisLite::viridis(5, alpha = 0.75),
    show_total = T,
    sparkline = F,
    tooltip_formatter = V8::JS("function(x) {return (x).toLocaleString('en-US') + ' t'}"),
    total_formatter = V8::JS("function (x) {return (x.globals.seriesTotals.reduce((a, b) => {return a + b}, 0)).toLocaleString('en-US') + ' t'}")
  )


  # Revenue tab
  mod_highlight_mun_server(id = "revenue-card-mun", var = "revenue", period = "month", n = 12)
  mod_summary_card_server2(id = "revenue-card-mun", var = "landing_revenue", period = "month", n = 13, i18n_r = i18n_r)
  mod_summary_card_server3(id = "revenue-card-mun", var = "n_landings_per_boat", period = "month", n = 13, i18n_r = i18n_r)
  mod_simple_summary_card_server(id = "revenue-card-mun", var = "n_boats", period = "month", i18n_r = i18n_r)
  mod_summary_table_server(id = "revenue-card-mun", vars = c("revenue", "recorded_revenue", "landing_revenue", "n_landings_per_boat"), i18n_r = i18n_r)
  mod_var_descriptions_server(id = "revenue-info", vars = c("revenue", "recorded_revenue", "landing_revenue", "n_landings_per_boat", "n_boats"), i18n_r = i18n_r)
  mod_normalized_treemap_server(
    data = peskas.timor.portal::summary_data$revenue_habitat,
    id = "habitat-revenue",
    colors = habitat_colors,
    y_formatter = apexcharter::format_num("$,.2f"),
    label_formatter = V8::JS("function (text, op) {return [text, '$' + op.value.toFixed(2)]}")
  )


  # Catch tab
  mod_highlight_mun_server(id = "catch-card-mun", var = "catch", period = "month", n = 12)
  mod_summary_card_server2(id = "catch-card-mun", var = "catch", period = "month", n = 12, i18n_r = i18n_r)
  mod_summary_card_server3(id = "catch-card-mun", var = "landing_weight", period = "month", n = 12, i18n_r = i18n_r)
  mod_simple_summary_card_server(id = "catch-card-mun", var = "n_boats", period = "month", i18n_r = i18n_r)
  mod_summary_table_server(id = "catch-card-mun", vars = c("catch", "recorded_catch", "landing_weight", "n_landings_per_boat"), i18n_r = i18n_r)
  mod_var_descriptions_server(id = "catch-info", vars = c("catch", "recorded_catch", "landing_weight", "n_landings_per_boat", "n_boats"), i18n_r = i18n_r)
  mod_normalized_treemap_server(
    data = peskas.timor.portal::summary_data$catch_habitat,
    id = "habitat-catch",
    colors = habitat_colors,
    y_formatter = apexcharter::format_num("$,.2f", suffix = " Kg"),
    label_formatter = V8::JS("function (text, op) {return [text, op.value.toFixed(2) + ' Kg']}")
  )


  # Market tab
  mod_highlight_mun_server(id = "market-card-mun", var = "price_kg", period = "month", n = 12)
  mod_summary_card_server2(id = "market-card-mun", var = "price_kg", period = "month", n = 12, i18n_r = i18n_r)
  mod_summary_card_server3(id = "market-card-mun", var = "landing_weight", period = "month", n = 12, i18n_r = i18n_r)
  mod_simple_summary_card_server(id = "market-card-mun", var = "n_boats", period = "month", i18n_r = i18n_r)
  mod_summary_table_server(id = "market-card-mun", vars = c("price_kg", "landing_weight", "n_landings_per_boat"), i18n_r = i18n_r, footer_value = "mean")
  mod_var_descriptions_server(id = "market-info", vars = "price_kg", i18n_r = i18n_r)
  apex_spider_server(id = "spider_market", data = peskas.timor.portal::municipal_aggregated, cols = c("#c57b57", "#96BDC6"))


  # Composition tab
  taxa_colors <- viridisLite::viridis(length(pars$taxa$to_display)) %>% strtrim(width = 7)
  mod_taxa_bar_highlight_server("taxa-highlight", var = "catch", colors = taxa_colors, i18n_r = i18n_r)
  mod_region_composition_server(id = "region-composition", legend_position = "top", legend_align = "center", legend_fontsize = 16, i18n_r = i18n_r)
  # mapply(pars$taxa$to_display[1:12], taxa_colors[1:12], FUN = function(x, y) {
  #  mod_summary_card_server(id = paste(x, "catch-card", sep = "-"), var = "catch", taxa = x, n = 25, colors = y)
  # })
  mod_composition_table_server(id = "taxa-table", i18n_r = i18n_r)
  mod_var_descriptions_server(id = "composition-info", vars = c("catch", "taxa"), i18n_r = i18n_r)

  # Tracks tab (dynamic map)
  leaflet_map_server(id = "map", marker_radius = 7, scale_markers = T, fill_marker_alpha = 0.6, legend_bins = 5, zoom = 8.5)
  mod_var_descriptions_server(id = "map-info", vars = c("pds_tracks_trips", "pds_tracks_cpe", "pds_tracks_rpe"), i18n_r = i18n_r)

  # Nutrition tab
  nutrients_colors <- c("#7ea0b7", "#376280", "#3d405b", "#969695", "#81b29a", "#945183", "#a98600")
  # nutrients_colors <- viridisLite::viridis(length(pars$nutrients$to_display)) %>% strtrim(width = 7)
  mod_nutrients_highlight_card_server("nutrients-highlight", var = "nut_rdi", period = "month", n = 25, colors = nutrients_colors)
  mapply(pars$nutrients$to_display, nutrients_colors, FUN = function(x, y) {
    mod_summary_card_server(id = paste(x, "nutrient-card", sep = "-"), var = "nut_rdi", nutrients = x, n = 25, colors = y)
  })
  mod_nutrient_treemap_server(
    id = "nutrient-tree", var = "nut_rdi", period = "month", n = NULL,
    type = "treemap", sparkline.enabled = F, y_formatter = apexcharter::format_num(""),
    colors = nutrients_colors
  )

  mod_var_descriptions_server(id = "nutrients-info", vars = "nut_rdi", i18n_r = i18n_r)

  # About tab
  timor_about_server(id = "about-text", content = pars$about$text, i18n_r = i18n_r)
}


#' Dummy apex chart
#'
#' @param type Plot type
#' @param sparkline.enabled Enable sparkline
#'
#' @return an htmlwidget
#' @import apexcharter
dummy_chart <- function(type = "bar", sparkline.enabled = TRUE) {
  apexchart() %>%
    ax_chart(
      type = type,
      toolbar = list(show = FALSE),
      sparkline = list(enabled = sparkline.enabled),
      animations = list(enabled = FALSE)
    ) %>%
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
