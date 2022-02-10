#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    apexchart_dep(),
    jquery_dep(),
    google_analytics(),
    shiny.i18n::usei18n(i18n),
    tabler_page(
      title = "Peskas | East Timor",
      header(
        logo = peskas_logo(),
        version_flex(
          heading = i18n$t(pars$header$subtitle$text),
          subheading = "East Timor (v0.0.12-alpha)"
        ),
        user_ui()
      ),
      tab_menu(
        tab_menu_item(i18n$t(pars$header$nav$home$text), "home", icon_home()),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$catch$text)
            ),
          id = "catch", icon_scale()),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$revenue$text)
          ),
          id = "revenue", icon_currency_dollar()),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$composition$text)
          ),
          "catch-composition", icon_chart_pie()),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$pds_tracks$text),
            tags$span(
              class = "badge bg-lime-lt",
              "New"
            )
          ),
          id = "pds_tracks", icon_boat()),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$nutrients$text),
            tags$span(
              class = "badge bg-red-lt ms-2",
              "Experimental"
            )
          ),
          id = "nutrients", icon_nutrients()),
        tab_menu_item(i18n$t(pars$header$nav$about$text), "about", icon_info_circle()),
        id = "main_tabset"
      ),
      tabset_panel(
        menu_id = "main_tabset",
        tab_panel(
          id = "home",
          page_heading(pretitle = i18n$t(pars$home$subtitle$text),
                       title = i18n$t(pars$home$title$text),
                       download_report_button(text=i18n$t(pars$home$report$text), icon_download())),
        page_cards(
            mod_summary_card_ui(id = "revenue-summary-card", div_class = "col-md-4"),
            mod_summary_card_ui(id = "catch-summary-card", div_class = "col-md-4"),
            mod_summary_card_ui(id = "women-prop-summary-card", div_class = "col-md-4"),
            mod_summary_card_ui(id = "landings-card", div_class = "col-md-4"),
            mod_summary_card_ui(id = "tracks-card", div_class = "col-md-4"),
            mod_summary_card_ui(id = "matched-card", div_class = "col-md-4"),
          )
        ),
        tab_panel(
          id = "revenue",
          tab_revenue_content(i18n)
        ),
        tab_panel(
          id = "catch",
          tab_catch_content(i18n)
        ),
        tab_panel(
          id = "catch-composition",
          tab_catch_composition(i18n)
        ),
        tab_panel(
          id = "pds_tracks",
          tab_tracks_content(i18n)
        ),
        tab_panel(
          id = "nutrients",
          tab_nutrients_content(i18n)
        ),
        tab_panel(
          id = "about",
          peskas_timor_about_ui(id = "about-text")
        )
        #tab_panel(
        #  id = "about",
        #  page_text(content = peskas_timor_about())
        #)
      ),
      footer_panel(
        left_side_elements = tags$li(
          class = "list-inline-item",
          i18n$t(pars$footer$update_time$text),
          format(peskas.timor.portal::data_last_updated, "%c")
        ),
        right_side_elements = tagList(
          inline_li_link(
            content = "Licence",
            href = "https://github.com/WorldFishCenter/peskas.timor.portal/blob/main/LICENSE.md"
          ),
          inline_li_link(
            content = i18n$t(pars$footer$nav$code$text),
            href = "https://github.com/WorldFishCenter/peskas.timor.portal"
          )
        ),
        bottom = i18n$t("Copyright © 2021 Peskas. All rights reserved.")
      ),
      inactivity_modal(timeout_seconds = 5*60),
      settings_modal(),
      shinyjs::useShinyjs()
    )
  )

}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @noRd
golem_add_external_resources <- function(){

  shiny::addResourcePath(
    'www', app_sys('app/www')
  )

  tags$head(
    # avoiding some overhead so that we don't need to use golem in production
    # favicon(),
    # bundle_resources(
      # path = app_sys('app/www'),
      # app_title = 'peskas.timor.portal'
    # )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}


apexchart_dep <- function(){
  htmltools::htmlDependency(
    name = "apexcharts",
    version = "3.26.2",
    src = c(href = "https://cdn.jsdelivr.net/npm/apexcharts@3.26.2/dist/"),
    script = "apexcharts.min.js"
  )
}


jquery_dep <- function(){
  htmltools::htmlDependency(
    name = "jquery",
    version = "3.6.0",
    src = c(href = "https://code.jquery.com/"),
    script = "jquery-3.6.0.min.js"
  )
}
