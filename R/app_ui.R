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
      tab_menu_item("About", "about", icon_info_circle())
    ),
    tabset_panel(
      tab_panel(
        id = "home",
        page_heading(pretitle = "Small scale fisheries", title = "Overview"),
        page_cards(
          summary_card(
            heading = "1,200",
            subheader = "Landing surveys",
            top_right_element = tags$span("Last month", class = "text-muted"),
            annotation = trend_annotation("10%", "up"),
            in_body = tags$div(
              class = "mt-3",
              apexcharter::apexchartOutput("testchart1", height = "40px")),
            card_class = "col-sm-12 col-md-4"
          ),
          summary_card(
            heading = 15,
            subheader = "Landing sites",
            # top_right_element = tags$span("Last month", class = "text-muted"),
            annotation = trend_annotation(),
            off_body = tags$div(
              class = "mt-0",
              apexcharter::apexchartOutput("testchart2", height = "40px")),
            card_class = "col-sm-12 col-md-4"
          ),
          summary_card(
            heading = 184,
            subheader = "Tracked boats",
            # top_right_element = tags$span("Last month", class = "text-muted"),
            annotation = trend_annotation("8%", "down"),
            in_body = tags$div(
              class = "mt-3",
              apexcharter::apexchartOutput("testchart3", height = "40px")),
            card_class = "col-sm-12 col-md-4"
          )
        )

      ),
      tab_panel(
        id = "about",
        page_heading(pretitle = "", title = "About")
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

