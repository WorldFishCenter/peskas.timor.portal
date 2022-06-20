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
    "Number of trips",
    "Catch per unit effort (Kg)",
    "Revenue per unit effort (USD)"
  )

  select <- selectInput(
    inputId = ns("param"),
    label = tags$div(style = c("font-weight: bolder"), "Indicator"),
    choices = indicators,
    selected = "Number of trips"
  )

  tab_map_leaflet(
    id = id,
    in_body = tagList(
      leaflet::leafletOutput(ns("map"), width = "100%", height = "100%"),
      absolutePanel(
        top = 10, right = 10,
        select
      )
    )
  )
}



#' leaflet_map Server Functions
#'
#' @noRd
leaflet_map_server <- function(id,
                               provider_tiles = "CartoDB.Positron",
                               zoom = 8,
                               radius = 6,
                               fill_marker_alpha = 0.5,
                               legend_bins = 5,
                               scale_markers_trips = FALSE) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    dat <- peskas.timor.portal::indicators_grid

    if (isTRUE(scale_markers_trips)) {
      radius <- ~ log(dat$trips) * 2
    } else {
      radius <- radius
    }

    output$map <- leaflet::renderLeaflet({
      # Use leaflet() here, and only include aspects of the map that
      # won't need to change dynamically (at least, not unless the
      # entire map is being torn down and recreated).
      leaflet::leaflet(dat, options = leaflet::leafletOptions(minZoom = 5)) %>%
        leaflet::setView(lat = -8.75, lng = 125.6, zoom = zoom) %>%
        leaflet::addProviderTiles(provider_tiles)
    })

    outputOptions(output, "map", suspendWhenHidden = FALSE)

    observe({
      # observe any change in user selections and set leaflet parameters accordingly
      if (input$param == "Catch per unit effort (Kg)") {
        var <- dat$CPE_log
        leg_title <- "Catch per </br> unit effort (Kg)"
        label_format <- leaflet::labelFormat(transform = function(x) exp(x), digits = 1)
      } else if (input$param == "Revenue per unit effort (USD)") {
        var <- dat$RPE_log
        leg_title <- "Revenue per </br> unit effort (USD)"
        label_format <- leaflet::labelFormat(transform = function(x) exp(x), digits = 1)
      } else if (input$param == "Number of trips") {
        var <- dat$trips_log
        leg_title <- "N. trips"
        label_format <- leaflet::labelFormat(transform = function(x) exp(x), digits = 0)
      }

      ##
      ## Leaflet map settings
      ##

      proxy <- leaflet::leafletProxy("map", data = dat)

      mypalette <- leaflet::colorNumeric(
        palette = "viridis",
        domain = var,
        na.color = "transparent",
        reverse = F
      )

      # Prepare the text for the tooltip:
      mytext <- paste(
        paste0("<B>", dat$region, "</B>"), "<br/>",
        "Mean region CPE: ", dat$region_cpe, "<br/>",
        "Mean region RPE: ", dat$region_rpe, "<br/>",
        "N. trips: ", dat$trips, "<br/>",
        "CPE: ", dat$CPE, "<br/>",
        "RPE: ", dat$RPE, sep = ""
      ) %>%
        lapply(htmltools::HTML)

      proxy %>%
        leaflet::clearControls() %>%
        leaflet::clearMarkers() %>%
        leaflet::addCircleMarkers(~Lng, ~Lat,
          fillColor = ~ mypalette(var),
          fillOpacity = fill_marker_alpha,
          color = "white",
          radius = radius,
          stroke = FALSE,
          label = mytext,
          labelOptions = leaflet::labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px")
        ) %>%
        leaflet::addLegend(
          pal = mypalette,
          labFormat = label_format,
          bins = legend_bins,
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
    leaflet_map_server("map", scale_markers_trips = T)
  }
  shinyApp(ui, server)
}

# leaflet_map_app()
