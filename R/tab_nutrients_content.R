tab_nutrients_content <- function(i18n) {
  tagList(
    page_heading(
      pretitle = i18n$t(pars$catch$subtitle$text),
      title = i18n$t(pars$nutrients$title$text)
    ),
    page_cards(
      mod_nutrients_highlight_card_ui("nutrients-highlight", i18n$t(pars$vars$nut_rdi$short_name), card_class = "col-12"),
      mod_nutrient_treemap_ui(id = "nutrient-tree", heading = i18n$t(pars$nutrients$treemap_average$title), shiny::markdown(i18n$t(pars$nutrients$treemap_average$description)), card_class = "col-12", apex_height = "8rem"),
      mod_normalized_treemap_ui(id = "habitat-nutrients", heading = i18n$t(pars$nutrients$treemap_kg$title), shiny::markdown(i18n$t(pars$nutrients$treemap_kg$description)), card_class = "col-12", apex_height = "28rem"),
      mod_var_descriptions_ui(
        id = "nutrients-info",
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
}
