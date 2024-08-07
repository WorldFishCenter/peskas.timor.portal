#' leaflet_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
leaflet_map_ui <- function(id, i18n) {
  ns <- NS(id)

  indicators <- c(
    "Catch per unit effort (Kg)",
    "Revenue per unit effort (USD)",
    "Catch length (cm)"
  )

  sel_indicator <- selectInput(
    inputId = ns("param"),
    label = tags$div(style = c("font-weight: bolder"), "Indicator"),
    choices = indicators,
    selected = "Catch per unit effort (Kg)"
  )

  sel_gear <- selectInput(
    inputId = ns("gear"),
    label = tags$div(style = c("font-weight: bolder"), "Gear type"),
    choices = c(
      "All gears", "Hand line", "Gill net", "Long line", "Spear gun",
      "Cast net", "Seine net", "Manual collection", "Trap"
    ),
    selected = "All gears"
  )

  sel_taxa <- selectizeInput(
    inputId = ns("taxa"),
    label = tags$div(style = c("font-weight: bolder"), "Fish group"),
    choices = c("All groups", peskas.timor.portal::label_groups_list),
    selected = "All groups",
    multiple = FALSE,
    options = list(plugins = list("drag_drop", "remove_button"))
  )

  max_date <- as.Date((format(Sys.Date() - 30, "%Y-%m-01")))

  time_slide <- sliderInput(
    inputId = ns("time"),
    label = tags$div(style = c("font-weight: bolder"), "Time range"),
    min = as.Date("2019-05-01"),
    max = max_date,
    value = c(as.Date("2019-05-01"), max_date),
    timeFormat = "%b %Y",
    ticks = T,
    step = 31
  )

  map_ui <-
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
          sel_taxa,
          time_slide
        )
      )
    )

  tagList(
    div(
      class = "title",
      # h2(p(i18n$t(pars$home$map$title), style = "color:#666a70")),
      p(i18n$t(pars$pds_tracks$description$map$caption), style = "color:#666a70"),
      p(i18n$t(pars$pds_tracks$description$map$note), style = "color:#666a70; font-weight:bold;")
    ),
    map_ui
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
                               legend_bins = 5,
                               scale_markers = TRUE) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Load map data
    full_dat <- peskas.timor.portal::indicators_grid

    # Collects map zoom value to scale markers size when zooming
    mapzoom <- reactive({
      input$map_zoom
    })

    taxa_in <- reactive({
      req(input$taxa)
    })

    # Reactive expression to user filtering options
    dat <- reactive({
      if (input$gear == "All gears" & taxa_in() %in% "All groups") {
        res <- full_dat[full_dat$month_date >= input$time[1] & full_dat$month_date <= input$time[2], ]
        res <- aggregate_reactive(res)
      } else if (input$gear == "All gears" & !taxa_in() %in% "All groups") {
        res <- full_dat[full_dat$month_date >= input$time[1] & full_dat$month_date <= input$time[2], ]
        res <- res[res$catch_taxon %in% c(taxa_in()), ]
        res <- aggregate_reactive(res)
      } else if (!input$gear == "All gears" & taxa_in() %in% "All groups") {
        res <- full_dat[full_dat$month_date >= input$time[1] & full_dat$month_date <= input$time[2], ]
        res <- res[res$gear_type == input$gear, ]
        res <- aggregate_reactive(res)
        #
      } else if (input$gear == "All gears" & is.null(taxa_in())) {
        res <- full_dat[full_dat$month_date >= input$time[1] & full_dat$month_date <= input$time[2], ]
        res <- aggregate_reactive(res)
      } else if (!input$gear == "All gears" & is.null(taxa_in())) {
        res <- full_dat[full_dat$month_date >= input$time[1] & full_dat$month_date <= input$time[2], ]
        res <- res[res$gear_type == input$gear, ]
        res <- aggregate_reactive(res)
        #
      } else {
        res <- full_dat[full_dat$month_date >= input$time[1] & full_dat$month_date <= input$time[2], ]
        res <- res[res$gear_type == input$gear, ]
        res <- res[res$catch_taxon %in% c(taxa_in()), ]
        res <- aggregate_reactive(res, package = "data.table")
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
      } else if (input$param == "Catch length (cm)") {
        var <- dat()$length_log
        leg_title <- "Catch length (cm)"
        label_format <- leaflet::labelFormat(transform = function(x) exp(x), digits = 1)
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
        "Municipality CPE: ", dat()$region_cpe, "<br/>",
        "Municipality RPE: ", dat()$region_rpe, "<br/>",
        "Mean length: ", dat()$length, "<br/>",
        "Mean CPUE: ", dat()$CPE, "<br/>",
        "Mean RPUE: ", dat()$RPE,
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

#' leaflet_cpue UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
leaflet_cpue_ui <- function(id) {
  ns <- NS(id)

  sel_gear <- selectInput(
    inputId = ns("gear"),
    label = tags$div(style = c("color: white"), "Select gear type"),
    choices = c(
      "All Gears", "Hand Line", "Gill Net", "Long Line", "Spear Gun",
      "Cast Net", "Seine Net", "Manual Collection", "Beach Seine"
    ),
    selected = "All Gears"
  )

  map_ui <-
    tab_map_leaflet(
      id = id,
      in_body = tagList(
        leaflet::leafletOutput(ns("map"), width = "100%", height = "100%"),
        shiny::absolutePanel(
          left = 65,
          top = 10,
          width = 330,
          sel_gear
        )
      )
    )

  tagList(
    div(
      class = "title",
    ),
    map_ui
  )
}


#' leaflet_cpue Server Functions
#'
#' @noRd
leaflet_cpue_server <- function(id, zoom = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    full_dat <- peskas.timor.portal::summary_data$region_cpue %>% dplyr::filter(!gear_type == "Trap")
    full_dat$gear_type <- stringr::str_to_title(full_dat$gear_type)

    timor_boundaries <- sf::st_as_sf(peskas.timor.portal::summary_data$timor_boundaries)

    # Reactive expression to user filtering options
    dat <- reactive({
      if (input$gear == "All Gears") {
        res <- full_dat %>%
          tidyr::complete(region, gear_type) %>%
          dplyr::group_by(region) %>%
          dplyr::summarise(cpue = mean(cpue, na.rm = T))
        res <- timor_boundaries %>%
          dplyr::left_join(res, by = "region") %>%
          dplyr::select(region, cpue, geometry)
      } else {
        res <- full_dat %>%
          tidyr::complete(region, gear_type) %>%
          dplyr::filter(gear_type == input$gear)
        res <- timor_boundaries %>%
          dplyr::left_join(res, by = "region") %>%
          dplyr::select(region, cpue, geometry)
      }
    })

    # Include aspects of the map that won't need to change dynamically
    output$map <- leaflet::renderLeaflet({
      leaflet::leaflet(timor_boundaries, options = leaflet::leafletOptions(minZoom = 5)) %>%
        leaflet::setView(lat = -8.75, lng = 125.7, zoom = zoom) %>%
        leaflet::addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/langbart/cli8oua4m002a01pg17wt6vqa/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibGFuZ2JhcnQiLCJhIjoiY2xkcGN0b3lhMDhmODNvbzQzNGlqbXI0OSJ9.JhvnRPg7hwJ5rPc5M5NChQ")
    })

    outputOptions(output, "map", suspendWhenHidden = FALSE)
    # Observe changes in user indicators selection and set legends and text accordingly
    observe({
      var <- dat()$cpue
      # Set colors
      mypalette <- leaflet::colorNumeric(
        palette = c(
          "#ffffff", "#f6fae6", "#f2fbd2", "#deedd8", "#c9ecb4",
          "#add9ba", "#93d3ab", "#64c0b5", "#35b0ab"
        ),
        domain = var,
        na.color = "transparent",
        reverse = F
      )

      # Set text for the tooltip:
      labels <- sprintf(
        "<div style='font-size:16px;'><strong>%s</strong><br/>Hourly catch rate per fisherman: <strong>%g kg</strong></div>",
        dat()$region, round(var, 3)
      ) %>%
        purrr::map(~ stringr::str_replace(., "NA kg", "No data")) %>%
        lapply(htmltools::HTML)

      leaflet::leafletProxy("map", data = dat()) %>%
        leaflet::clearShapes() %>%
        leaflet::clearControls() %>%
        leaflet::addPolygons(
          color = "transparent",
          weight = 2,
          smoothFactor = 1,
          opacity = 1,
          fillOpacity = 0.8,
          fillColor = ~ mypalette(var),
          label = labels,
          highlightOptions = leaflet::highlightOptions(
            color = "white", weight = 4,
            bringToFront = TRUE
          ),
          layerId = dat()$region
        ) %>%
        leaflet::addLegend(
          pal = mypalette,
          opacity = 0.9,
          # bins = 2,
          values = ~var,
          className = "custom-legend",
          title = htmltools::HTML("Hourly catch rate<br/>per fisherman (kg)"),
          position = "bottomright"
        )
    })
  })
}


leaflet_map_app <- function(i18n) {
  ui <- tabler_page(
    tags$div(leaflet_map_ui(id = "map", i18n))
  )

  server <- function(input, output, session) {
    leaflet_map_server("map", scale_markers = F)
  }
  shinyApp(ui, server)
}

tab_map_leaflet <- function(id, in_body) {
  tags$div(
    class = "card",
    tags$div(
      class = "card-body",
      style = "position: relative;",
      tags$div(
        class = "ratio ratio-21x9",
        tags$div(
          id = id,
          class = "in-body",
          # style = "background-color: transparent;",
          in_body
        )
      )
    )
  )
}


# leaflet_map_app(i18n)


aggregate_reactive <- function(x, package = "data.table") {
  if (package == "data.table") {
    x <- data.table::as.data.table(x)
    x <-
      x[, .(
        region = data.table::first(region),
        Lat = median(Lat),
        Lng = median(Lng),
        region_cpe = data.table::first(region_cpe),
        region_rpe = data.table::first(region_rpe),
        CPE = round(mean(CPE, na.rm = T), 2),
        RPE = round(mean(RPE, na.rm = T), 2),
        length = round(mean(length, na.rm = T), 2)
      ), by = "cell"]

    x[, ":="(
      length_log = log(length + 1),
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
        length = sum(length),
        length_log = log(length + 1),
        region_cpe = dplyr::first(region_cpe),
        region_rpe = dplyr::first(region_rpe),
        CPE = round(mean(CPE, na.rm = T), 2),
        RPE = round(mean(RPE, na.rm = T), 2),
        CPE_log = log(CPE + 1),
        RPE_log = log(RPE + 1)
      ) %>%
      dplyr::ungroup()
  } else {
    stop("you must choose one of data.table or dplyr packages to aggregate data")
  }
  x
}


format_hexbin_data <- function(data, input = NULL) {
  if (input == "Catch per unit effort (Kg)") {
    res <- data[, .(Lat, Lng, CPE)]
    res <- res[, CPE := CPE * 10]
    res <- setDT(res)[, .(CPE = 1:CPE), by = .(Lat, Lng)]
  } else if (input == "Revenue per unit effort (USD)") {
    res <- data[, .(Lat, Lng, RPE)]
    res <- res[, RPE := RPE * 10]
    res <- setDT(res)[, .(RPE = 1:RPE), by = .(Lat, Lng)]
  } else if (input == "Number of trips") {
    res <- data[, .(Lat, Lng, trips)]
    res <- setDT(res)[, .(trips = 1:trips), by = .(Lat, Lng)]
  }
  res
}


#' Render HTML Kepler map
#'
#' @description Render a Kepler map as a HTML file
#'
#' @param width HTML object width
#' @param height HTML object height
#'
#' @noRd
#'
kepler_map <- function(width = NULL, height = NULL, i18n) {
  addResourcePath(
    prefix = "www",
    directoryPath = system.file("app/www", package = "peskas.timor.portal")
  )
  tagList(
    div(
      class = "title",
      h2(p(i18n$t(pars$home$map$title), style = "color:#666a70")),
      p(i18n$t(pars$home$map$caption), style = "color:#666a70")
    ),
    htmltools::tags$iframe(src = "www/kepler_pds_map.html", width = width, height = height)
  )
}



fishing_map_ui <- function(id) {
  ns <- NS(id)
  color_range <- list(
    c(1, 152, 189),
    c(73, 227, 206),
    c(216, 254, 181),
    c(254, 237, 177),
    c(254, 173, 84),
    c(209, 55, 78)
  )
  div(
    style = "position: relative; width: 100%; height: 650px;", # Adjust height as needed
    tags$head(
      tags$style(shiny::HTML("
        .legend {
          margin-top: 15px;
          display: flex;
        }
        .legend-item {
          flex-grow: 1;
          height: 20px;
          min-width: 45px;
        }
        .panel {
          background: rgba(255,255,255,0.8);
          padding: 20px;
          border-radius: 5px;
          max-width: 300px;
          z-index: 1000;
        }
        .panel h2, .panel p {
          margin: 0;
          padding: 0;
          color: black;
        }
        .legend span {
          color: black;
        }
        .checkbox-inline {
          display: block;
          margin-top: 10px;
        }
        .bold-label {
          font-weight: bold;
        }
        .checkbox-inline input[type='checkbox'] {
          accent-color: #0073b7;
        }
        .checkbox-inline input[type='checkbox']:checked {
          background-color: #0073b7;
          border-color: #0073b7;
        }
        .info-icon {
  display: inline-block;
  width: 18px;
  height: 18px;
  background-color: #0073b7;
  color: white;
  border-radius: 50%;
  text-align: center;
  line-height: 18px;
  cursor: help;
  margin-left: 5px;
  position: relative;
}
.info-icon::after {
  content: attr(data-tooltip);
  display: block;
  opacity: 0;
  position: absolute;
  background-color: #2c353c;
  border: 1px solid #f9f9f9;
  padding: 8px;
  border-radius: 5px;
  z-index: 1001;
  width: 200px;
  font-size: 0.9em;
  left: 50%;
  top: 100%;
  transform: translateX(-50%);
  margin-top: 10px;
  transition: opacity 0.4s ease;
  pointer-events: none; /* Prevents hover issues */
}

.info-icon:hover::after {
  opacity: 0.9;
}
      "))
    ),
    deckgl::deckglOutput(ns("map"), height = "100%"),
    div(
      class = "panel panel-default",
      style = "position: absolute; top: 20px; right: 20px;",
      h2("Fishing Activity Heatmap"),
      p(
        "Visualizing fishing vessel density in Timor-Leste waters",
        span(
          class = "info-icon",
          "ℹ",
          `data-tooltip` = "This heatmap shows the fishing vessel density along the Timor-Leste coasts. The data is based on a sample of 440 vessels equipped with GPS trackers, representing a subset of the total fishery. The gear type was predicted using a machine learning model analyzing the vessels' movement patterns."
        )
      ),
      div(
        class = "legend",
        lapply(1:6, function(i) {
          div(
            class = "legend-item",
            style = sprintf(
              "background-color: rgb(%s);",
              paste(color_range[[i]], collapse = ",")
            )
          )
        })
      ),
      div(
        style = "display: flex; justify-content: space-between; margin-top: 10px;",
        span("Low Density"),
        span("High Density")
      ),
      div(
        style = "margin-top: 15px;",
        span(class = "bold-label", "Gear Types:"),
        checkboxGroupInput(ns("Gear"), NULL,
          choices = unique(peskas.timor.portal::predicted_tracks$Gear),
          selected = unique(peskas.timor.portal::predicted_tracks$Gear),
          inline = TRUE
        )
      ),
      div(
        style = "margin-top: 15px;",
        span(class = "bold-label", "Time Range:"),
        sliderInput(ns("year_range"), NULL,
          min = min(peskas.timor.portal::predicted_tracks$year),
          max = max(peskas.timor.portal::predicted_tracks$year),
          value = c(min(peskas.timor.portal::predicted_tracks$year), max(peskas.timor.portal::predicted_tracks$year)),
          step = 1,
          sep = "",
          ticks = FALSE
        )
      ),
      div(
        style = "margin-top: 15px;",
        span(class = "bold-label", "Radius (meters):"),
        sliderInput(ns("radius"), NULL, min = 500, max = 3000, value = 500, step = 500, ticks = FALSE)
      ),
      p(
        style = "margin-top: 15px; font-size: 0.9em;",
        "Click on a hexagon to view detailed fishing activity information."
      )
    )
  )
}

# Define server logic for the module
fishing_map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    color_range <- list(
      c(1, 152, 189),
      c(73, 227, 206),
      c(216, 254, 181),
      c(254, 237, 177),
      c(254, 173, 84),
      c(209, 55, 78)
    )

    filtered_data <- reactive({
      peskas.timor.portal::predicted_tracks %>%
        dplyr::filter(
          Gear %in% input$Gear,
          year >= input$year_range[1],
          year <= input$year_range[2]
        )
    })

    props <- list(
      autoHighlight = TRUE,
      material = list(
        ambient = 0.75,
        diffuse = 0.75,
        specularColor = c(51, 51, 51)
      ),
      transitions = list(
        elevationScale = 3000
      )
    )

    tooltip_js <- htmlwidgets::JS("object => {
      const gearCounts = object.points.reduce((acc, point) => {
        acc[point.Gear] = (acc[point.Gear] || 0) + 1;
        return acc;
      }, {});

      const totalActivities = object.points.length;
      const mainGear = Object.keys(gearCounts).reduce((a, b) => gearCounts[a] > gearCounts[b] ? a : b);

      let backgroundColor = 'rgba(255, 255, 255, 0.9)'; // default white
      if (mainGear.toLowerCase().includes('long line')) {
        backgroundColor = 'rgba(204, 51, 99, 1)'; // light red
      } else if (mainGear.toLowerCase().includes('gill net')) {
        backgroundColor = 'rgba(51, 55, 69, 1)'; // light green
      } else if (mainGear.toLowerCase().includes('hand line')) {
        backgroundColor = 'rgba(188, 175, 156, 1)'; // light blue
      }

      const gearInfo = Object.entries(gearCounts)
        .map(([gear, count]) => `<strong>${gear}:</strong> ${count} (${(count/totalActivities*100).toFixed(1)}%)`)
        .join('<br>');

      return `
        <div style='background-color: ${backgroundColor}; padding: 10px; border-radius: 5px;'>
          <strong>Location:</strong> ${object.position[1].toFixed(4)}, ${object.position[0].toFixed(4)}<br>
          <strong>Total Activities:</strong> ${totalActivities}<br>
          <strong>Gear Types:</strong><br>
          ${gearInfo}
        </div>
      `;
    }")

    output$map <- deckgl::renderDeckgl({
      deckgl::deckgl(
        longitude = 125.7,
        latitude = -8.75,
        zoom = 8,
        pitch = 40.5
      ) %>%
        deckgl::add_basemap(
          style = deckgl::use_carto_style(theme = "dark-matter")
        ) %>%
        deckgl::add_hexagon_layer(
          data = peskas.timor.portal::predicted_tracks,
          getPosition = ~ c(lon, lat),
          colorRange = color_range,
          elevationRange = c(0, 3000),
          elevationScale = 30,
          extruded = TRUE,
          radius = 500, # Default radius
          coverage = 0.4,
          pickable = TRUE,
          properties = props,
          getTooltip = tooltip_js
        )
    })

    # Update the layer when inputs change
    observe({
      deckgl::deckgl_proxy(ns("map")) %>%
        deckgl::add_hexagon_layer(
          data = filtered_data(),
          getPosition = ~ c(lon, lat),
          colorRange = color_range,
          elevationRange = c(0, 3000),
          elevationScale = 30,
          extruded = TRUE,
          radius = input$radius,
          coverage = 0.4,
          pickable = TRUE,
          properties = props,
          getTooltip = tooltip_js
        ) %>%
        deckgl::update_deckgl()
    })
  })
}
