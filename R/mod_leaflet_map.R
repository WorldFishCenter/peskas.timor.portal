#' leaflet_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
leaflet_map_ui <- function(id) {
  ns <- NS(id)

  indicators <- c(
    "Catch per unit effort",
    "Number of trips",
    "Revenue per unit effort"
  )

  select <- selectInput(
    inputId = ns("param"),
    label = tags$div(style = c("font-weight: bolder"), "Parameter"),
    choices = indicators,
    selected = "Catch per unit effort"
  )

  tags$div(
    class = "card",
    tags$div(
      class = "card-body",
      tags$div(
        class = "ratio ratio-21x9",
        tags$div(
          tags$div(
            id = id,
            class = "w-100 h-100 jvm-container",
            style = "background-color: transparent;",
            tagList(
              leaflet::leafletOutput(ns("map"), width = "100%", height = "100%"),
              absolutePanel(
                top = 10, right = 10,
                select
              )
            )
          )
        )
      )
    )
  )
}

#' leaflet_map Server Functions
#'
#' @noRd
leaflet_map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    tracks_grid <- peskas.timor.portal::indicators_gridded


    output$map <- leaflet::renderLeaflet({
      # Use leaflet() here, and only include aspects of the map that
      # won't need to change dynamically (at least, not unless the
      # entire map is being torn down and recreated).
      leaflet::leaflet(tracks_grid, options = leaflet::leafletOptions(minZoom = 5)) %>%
        leaflet::setView(lat = -8.75, lng = 125.6, zoom = 8.5) %>%
        leaflet::addProviderTiles("CartoDB.Positron")
    })

    outputOptions(output, "map", suspendWhenHidden = FALSE)

    observe({
      # observe any change in user selections and set leaflet parameters accordingly
      if (input$param == "Catch per unit effort") {
        var <- tracks_grid$CPE_log
        leg_title <- "Catch per </br> unit effort (Kg)"
        label_format <- leaflet::labelFormat(transform = function(x) exp(x), digits = 1)
      } else if (input$param == "Revenue per unit effort") {
        var <- tracks_grid$RPE
        leg_title <- "Revenue per </br> unit effort (USD)"
        label_format <- leaflet::labelFormat(digits = 1)
      } else if (input$param == "Number of trips") {
        var <- tracks_grid$trips
        leg_title <- "N. trips"
        label_format <- leaflet::labelFormat(digits = 1)
      }

      ##
      ## Leaflet map settings
      ##

      proxy <- leaflet::leafletProxy("map", data = tracks_grid)

      mypalette <- leaflet::colorNumeric(
        palette = "viridis",
        domain = var,
        na.color = "transparent",
        reverse = F
      )

      # Prepare the text for the tooltip:
      mytext <- paste(
        paste0("<B>", tracks_grid$region, "</B>"), "<br/>",
        "Mean CPE: ", tracks_grid$region_cpe, "<br/>",
        "Mean RPE: ", tracks_grid$region_rpe, "<br/>",
        "CPE: ", tracks_grid$CPE, "<br/>",
        "RPE: ", tracks_grid$RPE, "<br/>",
        "N. trips: ", tracks_grid$trips,
        sep = ""
      ) %>%
        lapply(htmltools::HTML)

      proxy %>%
        leaflet::clearControls() %>%
        leaflet::clearMarkers() %>%
        leaflet::addCircleMarkers(~Lng, ~Lat,
          fillColor = ~ mypalette(var),
          fillOpacity = 0.5,
          color = "white",
          radius = 6,
          stroke = FALSE,
          label = mytext,
          labelOptions = leaflet::labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px")
        ) %>%
        leaflet::addLegend(
          pal = mypalette,
          labFormat = label_format,
          bins = 5,
          values = ~var,
          className = "panel panel-default",
          title = leg_title,
          position = "bottomright"
        )
    })
  })
}

leaflet_map_app <- function() {
  ui <- tabler_page(
    tags$div(leaflet_map_ui(id = "map"))
  )

  server <- function(input, output, session) {
    leaflet_map_server("map")
  }
  shinyApp(ui, server)
}

#leaflet_map_app()
