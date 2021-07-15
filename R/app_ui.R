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
      tab_menu_item("Home", "home"),
      tab_menu_item("About", "about")
    ),
    tabset_panel(
      tab_panel(
        id = "home",
        # page_header(pretitle = "Small scale fisheries", title = "Overview"),

      ),
      tab_panel(
        id = "about",
        # page_header(pretitle = "", title = "About")
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

