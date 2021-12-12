tab_revenue_content <- function(i18n){
  tagList(
    page_heading(pretitle = i18n$t(pars$revenue$subtitle$text),
                 title = i18n$t(pars$revenue$title$text)),
    page_cards(
      tags$div(
        class = "col-12 mt-0",
        alert_ui(
          heading = i18n$t(pars$revenue$warning_1$heading$text),
          icon = icon_alert_triangle(class = "alert-icon"),
          content = i18n$t(pars$revenue$warning_1$content$text),
          alert_class = "alert-warning alert-dismissible mb-0 mt-2",
          bottom = tags$div(
            class = "btn-list d-lg-none mt-3",
            tags$a(
              href = "#revenue-info",
              class = "btn btn-warning",
              i18n$t(pars$revenue$warning_1$more$text)
            )
          )
        )
      ),
      tags$div(
        class = "col-lg-8 col-xl-8",
        mod_highlight_card_ui(
          id = "revenue-card",
          card_class = "col",
          apex_height = "21rem",
          heading = i18n$t(pars$vars$revenue$short_name)),
      ),
      tags$div(
        class = "col-lg-4 col-xl-4",
        tags$div(
          class = "row row-cards",
          mod_summary_card_ui(id = "landing-revenue-card", div_class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui(id = "landing-per-boat-revenue-card", div_class = "col-12 col-md-6 col-lg-12"),
          mod_simple_summary_card_ui(id = "n-boats-revenue-card", div_class = "col-12"),
        )
      ),
      mod_summary_table_ui(
        id = "revenue-table",
        heading = i18n$t(pars$revenue$table$heading$text),
        card_class = "col-lg-7 col-xl-auto order-lg-last"
      ),
      tags$div(
        class = "col",
        mod_var_descriptions_ui(
          id = "revenue-info",
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
