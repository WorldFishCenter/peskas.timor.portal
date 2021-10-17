#' Page heading for the
#'
#' @param pretitle Text to appear on top of title
#' @param title Text to appear as the title
#' @param ... Elements to add at the right hand side of the title (e.g. buttons, etc)
#'
#' @return a shiny tag
#'
page_heading <- function(pretitle = "Page pretitle", title = "Page title", download_text = "Download text", ...){
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
          ),
        ),
        tags$div(
          class = "col-auto ms-auto d-print-none",
          tags$div(
            class = "btn-list",
            tags$a(
              href = "https://storage.googleapis.com/public-timor-dev/data_report.pdf",
              target = "_blank",
              class = "btn btn-primary d-none d-sm-inline-block",
              tags$svg(
                xmlns = "http://www.w3.org/2000/svg",
                class = "icon",
                width = "24",
                height = "24",
                viewbox = "0 0 24 24",
                `stroke-width` = "2",
                stroke = "currentColor",
                fill = "none",
                `stroke-linecap` = "round",
                `stroke-linejoin` = "round",
                tags$path(
                  stroke = "none",
                  d = "M0 0h24v24H0z",
                  fill = "none"
                ),
                tags$path(d = "M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-2"),
                tags$polyline(points = "7 11 12 16 17 11"),
                tags$line(
                  x1 = "12",
                  y1 = "4",
                  x2 = "12",
                  y2 = "16"
                )
              ),
              download_text
            )
          )
        )
      )
    )
  )
}
