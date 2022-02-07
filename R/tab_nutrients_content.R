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
      ),
      tags$div(
        class = "col-lg-8 col-xl-8",
        mod_highlight_card_ui(
          id = "vitaminA-card",
          card_class = "col",
          apex_height = "21rem",
          heading = i18n$t(pars$vars$vitaminA$short_name)
        ),
      ),
      tags$div(
        class = "col-lg-4 col-xl-4",
        tags$div(
          class = "row row-cards",
          mod_summary_card_ui(id = "nutrients-selenium", div_class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui(id = "nutrients-iron", div_class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui(id = "nutrients-calcium", div_class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui(id = "nutrients-zinc", div_class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui(id = "nutrients-vitaminA", div_class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui(id = "nutrients-omega3", div_class = "col-12 col-md-6 col-lg-12")
        )
      )
    )
  )
}
