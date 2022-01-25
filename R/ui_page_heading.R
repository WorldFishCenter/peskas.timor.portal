#' Page heading for the
#'
#' @param pretitle Text to appear on top of title
#' @param title Text to appear as the title
#' @param ... Elements to add at the right hand side of the title (e.g. buttons, etc)
#'
#' @return a shiny tag
#'
page_heading <- function(pretitle = "Page pretitle", title = "Page title", ...) {
  tags$div(
    class = "container-xl",
    tags$div(
      class = "page-header d-print-none",
      tags$div(
        class = "row align-items-center",
        tags$div(
          class = "col",
          tags$div(
            class = "page-pretitle",
            pretitle
          ),
          tags$h2(
            class = "page-title",
            title
          )
        ),
        ...
      )
    )
  )
}


download_report_button <- function(text = NULL, icon = NULL) {
  tags$div(
    class = "col-auto ms-auto d-print-none",
    tags$div(
      class = "btn-list",
      tags$a(
        href = "https://storage.googleapis.com/public-timor/data_report.pdf",
        target = "_blank",
        class = "btn btn-primary d-none d-sm-inline-block",
        icon,
        text
      )
    )
  )
}
