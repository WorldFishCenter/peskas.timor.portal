tab_home_content <- function(i18n) {
  tagList(
    home_text(title = i18n$t(pars$home$intro$title), content = i18n$t(pars$home$intro$content), report_text = i18n$t(pars$home$report$text)),
    page_cards(
      fishing_map_ui(id = "fishing_map"),
      # kepler_map(width = "580", height = "510", i18n),
      apex_summary_ui(id = "donut_trips", div_class = "col-md-4", apex_height = "16rem"),
      apex_summary_ui(id = "donut_revenue", div_class = "col-md-4", apex_height = "16rem"),
      apex_summary_ui(id = "donut_fish", div_class = "col-md-4", apex_height = "16rem"),
      mod_table_react_ui(id = "home_table")
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
