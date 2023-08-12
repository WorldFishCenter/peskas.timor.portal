tab_revenue_content <- function(i18n) {
  tagList(
    page_heading(
      pretitle = i18n$t(pars$catch$subtitle$text),
      title = i18n$t(pars$header$nav$revenue$text)
    ),
    page_cards(
      mun_select("revenue-card-mun", header = i18n$t(pars$revenue$area_dropdown$text))
    ),
    page_cards(
      tags$div(
        class = "col-lg-8 col-xl-8",
        mod_highlight_mun_ui(
          id = "revenue-card-mun",
          card_class = "col",
          apex_height = "21rem",
          heading = i18n$t(pars$vars$revenue$short_name)
        ),
      ),
      tags$div(
        class = "col-lg-4 col-xl-4",
        tags$div(
          class = "row row-cards",
          mod_summary_card_ui2(id = "revenue-card-mun", div_class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui3(id = "revenue-card-mun", div_class = "col-12 col-md-6 col-lg-12"),
          mod_simple_summary_card_ui(id = "revenue-card-mun", div_class = "col-12"),
        )
      ),
      mod_normalized_treemap_ui(id = "habitat-revenue", heading = i18n$t(pars$revenue$treemap$title), shiny::markdown(i18n$t(pars$revenue$treemap$description)), card_class = "col-12", apex_height = "28rem"),
      mod_summary_table_ui(
        id = "revenue-card-mun",
        heading = i18n$t(pars$revenue$table$heading$text),
        card_class = "col-lg-7 col-xl-auto order-lg-last"
      ),
      tags$div(
        class = "col",
        mod_var_descriptions_ui(
          id = "revenue-info",
          heading = i18n$t(pars$revenue$description$heading$text),
          # subheading = "Possible caveats and data description",
          intro = tagList(
            markdown(i18n$t(pars$revenue$description$content$text)),
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
