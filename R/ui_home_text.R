home_text <- function(i18n) {
  div(
    class = "card-body",
    div(
      class = "row align-items-center",
      div(
        class = "col-10",
        h3(
          class = "h1",
          i18n$t(pars$home$intro$title)
        ),
        div(
          class = "markdown text-muted",
          i18n$t(pars$home$intro$content),
        ),
        div(
          class = "mt-3",
          a(
            href = "https://storage.googleapis.com/public-timor/data_report.pdf",
            class = "btn btn-primary",
            target = "_blank",
            rel = "noopener",
            icon_download(),
            i18n$t(pars$home$report$text)
          )
        )
      )
    )
  )
}
