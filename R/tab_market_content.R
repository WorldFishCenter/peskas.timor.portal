tab_market_content <- function(i18n) {
  tagList(
    page_heading(
      pretitle = i18n$t(pars$market$subtitle$text),
      title = i18n$t(pars$market$title$text)
    ),
    page_cards(
      mun_select("market-card-mun")
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
        mod_highlight_mun_ui(
          id = "market-card-mun",
          card_class = "col",
          apex_height = "21rem",
          heading = i18n$t(pars$vars$price_kg$short_name)
        )
      ),
      tags$div(
        class = "col-lg-4 col-xl-4",
        tags$div(
          class = "row row-cards",
          tags$div(apexchartOutput("spider_market", width = "100%", height = "16rem"), class = "col-12 col-md-6 col-lg-12"),
          mod_summary_card_ui2(id = "market-card-mun", div_class = "col-12 col-md-6 col-lg-12"),
          #mod_summary_card_ui3(id = "market-card-mun", div_class = "col-12 col-md-6 col-lg-12"),
          mod_simple_summary_card_ui(id = "market-card-mun", div_class = "col-12"),
        )
      ),
      mod_summary_table_ui(
        id = "market-card-mun",
        heading = i18n$t(pars$market$table$heading$text),
        card_class = "col-lg-7 col-xl-auto order-lg-last"
      ),
      tags$div(
        class = "col",
        mod_var_descriptions_ui(
          id = "market-info",
          heading = i18n$t(pars$market$description$heading$text),
          # subheading = "Possible caveats and data description",
          intro = tagList(
            markdown(i18n$t(pars$market$description$content$text)),
            tags$div(
              class = "hr-text",
              i18n$t(pars$market$description$subheading$text)
            )
          )
        )
      )
    )
  )
}