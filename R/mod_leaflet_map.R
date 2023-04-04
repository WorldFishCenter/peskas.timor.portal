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
      h2(p(i18n$t(pars$home$map$title), style = "color:#666a70")),
      p(i18n$t(pars$home$map$caption), style = "color:#666a70"),
      p(i18n$t(pars$home$map$note), style = "color:#666a70; font-weight:bold;")
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


#leaflet_map_app(i18n)


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
