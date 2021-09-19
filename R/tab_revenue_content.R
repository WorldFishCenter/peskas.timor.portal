tab_revenue_content <- function(i18n){
  tagList(
    page_heading(pretitle = i18n$t("Small scale fisheries"), title = i18n$t("National revenue")),
    page_cards(
      tags$div(
        class = "col-12 mt-0",
        alert_ui(
          heading = i18n$t("Estimates are provisional"),
          icon = icon_alert_triangle(class = "alert-icon"),
          content = i18n$t("These estimates have not been validated and might be inaccurate. Use with caution."),
          alert_class = "alert-warning alert-dismissible mb-0 mt-2",
          bottom = tags$div(
            class = "btn-list d-lg-none mt-3",
            tags$a(
              href = "#revenue-info",
              class = "btn btn-warning",
              i18n$t("Learn more")
            )
          )
        )
      ),
      tags$div(
        class = "col-lg-8 col-xl-9",
        mod_highlight_card_ui(id = "revenue-card", card_class = "col", apex_height = "21rem"),
      ),
      tags$div(
        class = "col-lg-4 col-xl-3",
        tags$div(
          class = "row row-cards",
          mod_summary_card_ui(id = "landing-revenue-card", div_class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui(id = "landing-per-boat-revenue-card", div_class = "col-12 col-md-6 col-lg-12"),
          mod_simple_summary_card_ui(id = "n-boats-revenue-card", div_class = "col-12"),
        )
      ),
      mod_summary_table_ui(
        id = "revenue-table",
        heading = "Annual summary",
        card_class = "col-lg-7 col-xl-auto order-lg-last"
      ),
      tags$div(
        class = "col",
        mod_var_descriptions_ui(
          id = "revenue-info",
          heading = "About the data",
          # subheading = "Possible caveats and data description",
          intro =  tagList(
            markdown(
              "
The revenue estimates have not been thoroughly validated and might be inaccurate.
There is some uncertainty on all data used in the calculations.

Estimates, even from previous years, may be updated whenever new data is available.
            "
            ),
            tags$div(
              class = "hr-text",
              "Indicator information"
            )
          )
        )
      ),

    )
  )
}
