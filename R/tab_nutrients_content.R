tab_nutrients_content <- function(i18n) {
  tagList(
    page_heading(
      pretitle = i18n$t(pars$catch$subtitle$text),
      title = i18n$t(pars$nutrients$title$text)
    ),
    page_cards(
      tags$div(
        class = "col-12 mt-0",
        alert_ui(
          heading = i18n$t(pars$revenue$warning_1$heading$text),
          icon = icon_alert_triangle(class = "alert-icon"),
          content = i18n$t(pars$revenue$warning_1$content$text),
          alert_class = "alert-warning alert-dismissible mb-0 mt-2",
          bottom = tags$div(
            class = "btn-list mt-3",
            tags$a(
              href = "#composition-info",
              class = "btn btn-warning",
              i18n$t(pars$revenue$warning_1$more$text)
            )
          )
        )
      )
    )
  )
}
