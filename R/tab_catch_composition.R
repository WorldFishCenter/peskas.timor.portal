tab_catch_composition <- function(i18n) {
  tagList(
    page_heading(
      pretitle = i18n$t(pars$catch$subtitle$text),
      title = i18n$t(pars$composition$title$text)
    ),
    page_cards(
      mod_table_react_ui("taxa-table", card_class = "col-12"),
      mod_taxa_bar_highlight_ui("taxa-highlight", i18n$t(pars$composition$highlight$heading$text), card_class = "col-12"),
      mod_region_composition_ui(id = "region-composition", heading = i18n$t(pars$composition$percent$heading$text), apex_height = "30rem"),
      # page_cards(
      #  lapply(peskas.timor.portal::taxa_names$grouped_taxa[1:12], function(x) {
      #    mod_summary_card_ui(id = paste(x, "catch-card", sep = "-"), div_class = "col-12 col-md-6 col-lg-4")
      #  })
      # ),
      tags$div(
        class = "col",
        mod_var_descriptions_ui(
          id = "composition-info",
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
