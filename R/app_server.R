#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  
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
