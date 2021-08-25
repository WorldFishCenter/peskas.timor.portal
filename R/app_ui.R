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
    tabler_page(
      title = "Peskas | East Timor",
      header(
        logo = peskas_logo(),
        version_flex(
          heading = "Managment Dashboard",
          subheading = "East Timor (v0.0.12-alpha)"
        )
      ),
      tab_menu(
        tab_menu_item("Home", "home", icon_home()),
        tab_menu_item(
          label = tagList(
            "Revenue",
            tags$span(
              class = "badge bg-lime-lt",
              "New"
            )
          ),
          id = "revenue", icon_currency_dollar()),
        tab_menu_item("About", "about", icon_info_circle()),
        id = "main_tabset"
      ),
      tabset_panel(
        menu_id = "main_tabset",
        tab_panel(
          id = "home",
          page_heading(pretitle = "Small scale fisheries report", title = "National overview - July 2021"),
          page_cards(
            mod_summary_card_ui(id = "revenue-summary-card", div_class = "col-md-3"),
            mod_summary_card_ui(id = "landings-card", div_class = "col-md-3"),
            mod_summary_card_ui(id = "tracks-card", div_class = "col-md-3"),
            mod_summary_card_ui(id = "matched-card", div_class = "col-md-3"),
          )
        ),
        tab_panel(
          id = "revenue",
          tab_revenue_content()
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
            content = "The project",
            href = "https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0234760"
          ),
          inline_li_link(
            content = "Licence",
            href = "https://github.com/WorldFishCenter/peskas.timor.portal/blob/main/LICENSE.md"
          ),
          inline_li_link(
            content = "Source code",
            href = "https://github.com/WorldFishCenter/peskas.timor.portal"
          )
        ),
        bottom = "Copyright © 2021 Peskas. All rights reserved."
      ),
      mod_inactivity_monitor_ui(id = "time-out-monitor", timeout_seconds = 60*5)
      # shinyjs::useShinyjs()
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
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){

  add_resource_path(
    'www', app_sys('app/www')
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'peskas.timor.portal'
    )
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
