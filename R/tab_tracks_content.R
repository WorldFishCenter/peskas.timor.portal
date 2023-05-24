tab_tracks_content <- function(i18n) {
  tagList(
    page_heading(
      pretitle = i18n$t(pars$catch$subtitle$text),
      title = i18n$t(pars$header$nav$pds_tracks$text)
    ),
    page_cards(
      tags$div(
        leaflet_map_ui(id = "map", i18n)
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
