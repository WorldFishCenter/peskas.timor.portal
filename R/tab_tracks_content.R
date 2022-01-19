tab_tracks_content <- function(i18n) {
  tagList(
    page_heading(
      pretitle = i18n$t(pars$pds_tracks$subtitle),
      title = i18n$t(pars$pds_tracks$title)
    ),
    page_cards(
      tags$img(
        src = "https://storage.googleapis.com/public-timor-dev/tracks-map.png", # png
        width = "100%"
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
