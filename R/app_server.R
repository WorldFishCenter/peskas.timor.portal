#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic
  # Summary tab
  mod_summary_card_server(id = "revenue-summary-card", var = "revenue", period = "month", n = 13)
  mod_summary_card_server(id = "landings-card", var = "n_landings", period = "month", n = 13)
  mod_summary_card_server(id = "tracks-card", var = "n_tracks", period = "month", n = 13)
  mod_summary_card_server(id = "matched-card", var = "n_matched", period = "month", n = 13)

  # Revenue tab
  mod_highlight_card_server(id = "revenue-card", var = "revenue", period = "month", n = 25)
  mod_summary_card_server(id = "landing-revenue-card", var = "landing_revenue", period = "month", n = 13)
  mod_summary_card_server(id = "landing-per-boat-revenue-card", var = "n_landings_per_boat", period = "month", n = 13)
  mod_summary_card_server(id = "n-boats-revenue-card", var = "n_boats", period = "month", n = 13)
  mod_summary_table_server(id = "revenue-table", vars = c("revenue", "landing_revenue", "n_landings_per_boat", "n_boats"))
  mod_var_descriptions_server(id = "revenue-info", vars = c("landing_revenue", "n_landings_per_boat", "n_boats", "revenue"))

  # observeEvent(input$link_to_tabpanel_b, {
  #   updateTabsetPanel(session, "main_tabset", "revenue")
  # })
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
