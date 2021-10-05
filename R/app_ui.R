#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  i18n <<- shiny.i18n::Translator$new(
    translation_json_path = system.file("translation.json", package = "peskas.timor.portal"))
  tagList(
    apexchart_dep(),
    jquery_dep(),
    tabler_page(
      title = "Peskas | East Timor",
      header(
        shiny.i18n::usei18n(i18n),
        logo = peskas_logo(),
        selectInput(
          inputId = 'language',
          label = i18n$t('Select your language'),
          choices = i18n$get_languages(),
          selected = i18n$get_key_translation(),
          width = '50%'
        ),
        version_flex(
          heading = i18n$t(pars$header$subtitle$text),
          subheading = "East Timor (v0.0.12-alpha)"
        )
      ),
      tab_menu(
        tab_menu_item(i18n$t(pars$header$nav$home$text), "home", icon_home()),
        tab_menu_item(
          label = tagList(
            i18n$t(pars$header$nav$revenue$text),
            tags$span(
              class = "badge bg-lime-lt",
              "New"
            )
          ),
          id = "revenue", icon_currency_dollar()),
        tab_menu_item(i18n$t(pars$header$nav$about$text), "about", icon_info_circle()),
        language_drop_item(i18n$t("Language"), "language", icon_world()),
        id = "main_tabset"
      ),
      tabset_panel(
        menu_id = "main_tabset",
        tab_panel(
          id = "home",
          page_heading(pretitle = i18n$t(pars$home$subtitle$text),
                       title = i18n$t(pars$home$title$text)),
          page_cards(
            mod_summary_card_ui(id = "revenue-summary-card", div_class = "col-md-3"),
            mod_summary_card_ui(id = "landings-card", div_class = "col-md-3"),
            mod_summary_card_ui(id = "tracks-card", div_class = "col-md-3"),
            mod_summary_card_ui(id = "matched-card", div_class = "col-md-3"),
          )
        ),
        tab_panel(
          id = "revenue",
          tab_revenue_content(i18n)
        ),
        tab_panel(
          id = "about",
          page_heading(pretitle = "", title = "About")
        )
      ),
      footer_panel(
        left_side_elements = tags$li(
          class = "list-inline-item",
          paste("Last updated", format(peskas.timor.portal::data_last_updated, "%c")),

        ),
        right_side_elements = tagList(
          inline_li_link(
            content = i18n$t(pars$footer$nav$project$text),
            href = "https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0234760"
          ),
          inline_li_link(
            content = i18n$t(pars$footer$nav$license$text),
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
      shinyjs::useShinyjs()
      # htmltools::suppressDependencies("apexcharts"),
      # apexchart_dep(),
      # jquery_dep()
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
