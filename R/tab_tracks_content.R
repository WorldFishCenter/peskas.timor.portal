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
          id = "map-info",
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


tab_map_leaflet <- function(id, in_body) {
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
          in_body
        )
      )
    )
  )
}
