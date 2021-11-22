tab_catch_composition <- function(i18n){
  tagList(
    page_heading(pretitle = i18n$t(pars$composition$subtitle$text),
                 title = i18n$t(pars$composition$title$text)),
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
      mod_taxa_bar_highlight_ui("taxa-highlight", i18n$t(pars$composition$highlight$heading$text), card_class = "col-12"),
      lapply(pars$taxa$to_display, function(x){
        mod_summary_card_ui(id = paste(x, "catch-card", sep = "-"), div_class = "col-12 col-md-6 col-lg-4")
      }),
      mod_composition_table_ui("taxa-table", heading = i18n$t(pars$composition$table$heading$text), card_class = "col-lg-7 col-xl-auto order-lg-last"),
      tags$div(
        class = "col",
        mod_var_descriptions_ui(
          id = "composition-info",
          heading = i18n$t(pars$revenue$description$heading$text),
          # subheading = "Possible caveats and data description",
          intro =  tagList(
            markdown(i18n$t(pars$revenue$description$content$text)),
            tags$div(
              class = "hr-text",
              i18n$t(pars$revenue$description$subheading$text)
            )
          )
        )
      ),
    )
  )
}
