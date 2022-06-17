tab_tracks_content <- function(i18n) {
  tagList(
    page_heading(
      pretitle = i18n$t(pars$pds_tracks$subtitle),
      title = i18n$t(pars$pds_tracks$title)
    ),
    page_cards(
      tags$div(
        leaflet_map_ui(id = "map")
      ),
      tags$div(
        class = "col",
        mod_var_descriptions_ui(
          id = "tracks-info",
          heading = i18n$t(pars$revenue$description$heading$text),
          # subheading = "Possible caveats and data description",
          intro = tagList(
            markdown(i18n$t(pars$pds_tracks$description$content$text)),
            tags$div(
              class = "hr-text",
              i18n$t(pars$revenue$description$subheading$text)
            )
          )
        )
      )
    )
  )
}


print_map <- function() {
  tracks_grid <- peskas.timor.portal::indicators_gridded

  mypalette <- leaflet::colorNumeric(
    palette = "viridis",
    domain = tracks_grid$CPE_log,
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

  # Final Map
  map <-
    leaflet::leaflet(tracks_grid, options = leaflet::leafletOptions(minZoom = 5)) %>%
    leaflet::addTiles() %>%
    leaflet::setView(lat = -8.75, lng = 126, zoom = 8) %>%
    leaflet::addProviderTiles("CartoDB.Positron") %>%
    leaflet::addCircleMarkers(~Lng, ~Lat,
      fillColor = ~ mypalette(CPE_log),
      fillOpacity = 0.5,
      color = "white",
      radius = 6,
      stroke = FALSE,
      label = mytext,
      labelOptions = leaflet::labelOptions(style = list("font-weight" = "normal", padding = "3px 8px"), textsize = "13px")
    ) %>%
    leaflet::addLegend(
      pal = mypalette,
      labFormat = leaflet::labelFormat(
        transform = function(x) exp(x),
        digits = 1
      ),
      bins = 5,
      values = ~ tracks_grid$CPE_log,
      className = "panel panel-default",
      title = "Catch per </br> unit effort (Kg)",
      position = "bottomright"
    )

  map
}


tab_map_leaflet <- function(id, ns, ...) {
  tags$div(
    class = "card",
    tags$div(
      class = "card-body",
      tags$div(
        class = "ratio ratio-21x9",
        tags$div(
          id = id,
          class = "w-100 h-100 jvm-container",
          style = "background-color: transparent;",
          tagList(
            leaflet::leafletOutput(ns(id), width = "100%", height = "100%"),
            absolutePanel(
              top = 10, right = 10,
              select
            )
          )
        )
      )
    )
  )
}
