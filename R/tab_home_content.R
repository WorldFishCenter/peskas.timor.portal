tab_home_content <- function(i18n) {
  tagList(
    home_text(title = i18n$t(pars$home$intro$title), content = i18n$t(pars$home$intro$content), report_text = i18n$t(pars$home$report$text)),
    page_cards(
      apex_summary_ui(id = "donut_trips", div_class = "col-md-4", apex_height = "16rem"),
      apex_summary_ui(id = "donut_fish", div_class = "col-md-4", apex_height = "16rem"),
      apex_summary_ui(id = "bar_tracks", div_class = "col-md-4", apex_height = "16rem"),
      mod_home_table_ui(id = "home_table"),
      leaflet_map_ui(id = "map", i18n)
      # HTML("<iframe src='https://kepler.gl/#/demo?mapUrl=https://raw.githubusercontent.com/WorldFishCenter/peskas.timor.portal/main/inst/peskas_CPUE.json' style='border:0px #ffffff none;' name='myiFrame' scrolling='no' frameborder='1' marginheight='0px' marginwidth='0px' height='500px' width='1000px' allowfullscreen></iframe>"),
    )
  )
}

home_text <- function(title = NULL, content = NULL, report_text) {
  div(
    class = "page-body",
    tags$div(
      class = "container-xl",
      div(
        class = "row align-items-center",
        div(
          class = "col-10",
          h3(
            class = "h1",
            title
          ),
          div(
            class = "markdown text-muted",
            content,
          ),
          div(
            class = "mt-3",
            a(
              href = "https://storage.googleapis.com/public-timor/data_report.html",
              class = "btn btn-primary",
              target = "_blank",
              rel = "noopener",
              icon_download(),
              report_text
            )
          )
        )
      )
    )
  )
}
