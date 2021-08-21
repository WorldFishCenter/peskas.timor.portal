#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
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
      tab_menu_item("Revenue", "revenue", icon_currency_dollar()),
      tab_menu_item("About", "about", icon_info_circle()),
      id = "main_tabset"
    ),
    tabset_panel(
      menu_id = "main_tabset",
      tab_panel(
        id = "home",
        page_heading(pretitle = "Small scale fisheries report - July 2021", title = "National overview"),
        page_cards(
          mod_summary_card_ui(id = "revenue-summary-card", card_class = "col-md-3"),
          mod_summary_card_ui(id = "landings-card", card_class = "col-md-3"),
          mod_summary_card_ui(id = "tracks-card", card_class = "col-md-3"),
          mod_summary_card_ui(id = "matched-card", card_class = "col-md-3"),
          # actionLink("link_to_tabpanel_b", "Link to panel B")
        )
      ),
      tab_panel(
        id = "revenue",
        page_heading(pretitle = "Small scale fisheries", title = "Revenue"),
        page_cards(
          tags$div(
            class = "col-md-8",
            mod_highlight_card_ui(id = "revenue-card", card_class = "col", apex_height = "22rem"),
          ),
          tags$div(
            class = "col-md-4",
            tags$div(
              class = "row row-cards",
              mod_summary_card_ui(id = "landing-revenue-card", card_class = "col-12"),
              mod_summary_card_ui(id = "landing-per-boat-revenue-card", card_class = "col-12"),
              mod_summary_card_ui(id = "n-boats-revenue-card", card_class = "col-12"),
            )

          ),

          mod_summary_table_ui(id = "revenue-table", heading = "Summary", card_class = "col-12"),

        )
      ),
      tab_panel(
        id = "about",
        page_heading(pretitle = "", title = "About")
      )
    ),
    footer_panel(
      left_side_elements = tags$li(
        class = "list-inline-item",
        "Copyright © 2021 Peskas. All rights reserved."
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
      )
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

