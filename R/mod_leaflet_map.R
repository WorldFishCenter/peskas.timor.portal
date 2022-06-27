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

  sel_indicator <- selectInput(
    inputId = ns("param"),
    label = tags$div(style = c("font-weight: bolder"), "Indicator"),
    choices = indicators,
    selected = "Number of trips"
  )

  sel_gear <- selectInput(
    inputId = ns("gear"),
    label = tags$div(style = c("font-weight: bolder"), "Gear type"),
    choices = c(
      "All gears", "Hand line", "Gill net", "Long line", "Spear gun",
      "Cast net", "Seine net", "Manual collection", "Trap"
    ),
    selected = "all gears"
  )

  time_slide <- sliderInput(
    inputId = ns("time"),
    label = tags$div(style = c("font-weight: bolder"), "Time range"),
    min = as.Date("2019-05-01"),
    max = as.Date("2022-05-01"),
    value = c(as.Date("2019-05-01"), as.Date("2022-05-01")),
    timeFormat = "%b %Y",
    ticks = T,
    step = 31
  )

  tab_map_leaflet(
    id = id,
    in_body = tagList(
      leaflet::leafletOutput(ns("map"), width = "100%", height = "100%"),
      absolutePanel(
        left = 65,
        top = 10,
        draggable = TRUE,
        width = 330,
        sel_indicator,
        sel_gear,
        time_slide
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
                               marker_radius = 7,
                               fill_marker_alpha = 0.6,
                               legend_bins = 8,
                               scale_markers = TRUE) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Load map data
    full_dat <- peskas.timor.portal::indicators_grid
    # Collects map zoom value to scale markers size when zooming
    mapzoom <- reactive({
      input$map_zoom
    })

    # Reactive expression to user filtering options
    dat <- reactive({
      if (input$gear == "All gears") {
        res <- full_dat[full_dat$month_date >= input$time[1] & full_dat$month_date <= input$time[2], ]
        res <- aggregate_reactive(res, package = "dplyr")
      } else {
        res <- full_dat[full_dat$month_date >= input$time[1] & full_dat$month_date <= input$time[2], ]
        res <- res[res$gear_type == input$gear, ]
        res <- aggregate_reactive(res, package = "dplyr")
      }
    })

    # Include aspects of the map that won't need to change dynamically
    output$map <- leaflet::renderLeaflet({
      leaflet::leaflet(full_dat, options = leaflet::leafletOptions(minZoom = 5)) %>%
        leaflet::setView(lat = -8.75, lng = 125.7, zoom = zoom) %>%
        leaflet::addProviderTiles(provider_tiles)
    })

    outputOptions(output, "map", suspendWhenHidden = FALSE)

    # Observe changes in user indicators selection and set legends and text accordingly
    observe({
      if (input$param == "Catch per unit effort (Kg)") {
        var <- dat()$CPE_log
        leg_title <- "Catch per </br> unit effort (Kg)"
        label_format <- leaflet::labelFormat(transform = function(x) exp(x), digits = 1)
      } else if (input$param == "Revenue per unit effort (USD)") {
        var <- dat()$RPE_log
        leg_title <- "Revenue per </br> unit effort (USD)"
        label_format <- leaflet::labelFormat(transform = function(x) exp(x), digits = 1)
      } else if (input$param == "Number of trips") {
        var <- dat()$trips_log
        leg_title <- "N. trips"
        label_format <- leaflet::labelFormat(transform = function(x) exp(x), digits = 0)
      }

      ##
      ## Leaflet map settings
      ##

      # Set colors
      mypalette <- leaflet::colorNumeric(
        palette = "viridis",
        domain = var,
        na.color = "transparent",
        reverse = F
      )

      # Set text for the tooltip:
      mytext <- paste(
        paste0("<B>", dat()$region, "</B>"), "<br/>",
        "Mean region CPE: ", dat()$region_cpe, "<br/>",
        "Mean region RPE: ", dat()$region_rpe, "<br/>",
        "N. trips: ", dat()$trips, "<br/>",
        "CPE: ", dat()$CPE, "<br/>",
        "RPE: ", dat()$RPE,
        sep = ""
      ) %>%
        lapply(htmltools::HTML)

      # Set markers radius
      if (isTRUE(scale_markers)) {
        radius <- mapzoom()
      } else {
        radius <- marker_radius
      }

      leaflet::leafletProxy("map", data = dat()) %>%
        leaflet::clearControls() %>%
        leaflet::clearMarkers() %>%
        leaflet::addCircleMarkers(~Lng, ~Lat,
          fillColor = ~ mypalette(var),
          fillOpacity = fill_marker_alpha,
          color = "white",
          radius = ~radius,
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
    leaflet_map_server("map", scale_markers_trips = F)
  }
  shinyApp(ui, server)
}

# leaflet_map_app()


aggregate_reactive <- function(x, package = "data.table") {
  if (package == "data.table") {
    x <- data.table::as.data.table(x)
    x <-
      x[, .(
        region = data.table::first(region),
        Lat = median(Lat),
        Lng = median(Lng),
        trips = sum(trips),
        region_cpe = data.table::first(region_cpe),
        region_rpe = data.table::first(region_rpe),
        CPE = stats::median(CPE, na.rm = T),
        RPE = stats::median(RPE, na.rm = T)
      ), by = "cell"]

    x[, ":="(
      trips_log = log(trips + 1),
      CPE_log = log(CPE + 1),
      RPE_log = log(RPE + 1)
    )]
  } else if (package == "dplyr") {
    x <-
      x %>%
      dplyr::group_by(cell) %>%
      dplyr::summarise(
        region = dplyr::first(region),
        Lat = median(Lat),
        Lng = median(Lng),
        trips = sum(trips),
        trips_log = log(trips + 1),
        region_cpe = dplyr::first(region_cpe),
        region_rpe = dplyr::first(region_rpe),
        CPE = median(CPE, na.rm = T),
        RPE = median(RPE, na.rm = T),
        CPE_log = log(CPE + 1),
        RPE_log = log(RPE + 1)
      ) %>%
      dplyr::ungroup()
  } else {
    stop("you must choose one of data.table or dplyr packages to aggregate data")
  }
  x
}
