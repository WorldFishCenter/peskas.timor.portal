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
        page_header(pretitle = "Small scale fisheries", title = "Overview"),

      ),
      tab_panel(
        id = "about",
        page_header(pretitle = "", title = "About")
      )
    )
  )
}
