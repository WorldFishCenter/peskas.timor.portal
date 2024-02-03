#' Add a header
#'
#' @param logo html for the logo
#' @param ... html tags to be included on the right hand side of the header
#'
header <- function(..., logo = NULL) {
  htmltools::tags$header(
    class = "navbar navbar-expand-md navbar-light d-print-none",
    htmltools::tags$div(
      class = "container-xl",
      htmltools::tags$button(
        class = "navbar-toggler",
        type = "button",
        `data-bs-toggle` = "collapse",
        `data-bs-target` = "#navbar-menu",
        htmltools::tags$span(class = "navbar-toggler-icon")
      ),
      htmltools::tags$h1(
        class = "navbar-brand navbar-brand-autodark d-none-navbar-horizontal pe-0 pe-md-3",
        htmltools::tags$a(
          href = ".",
          logo
        )
      ),
      htmltools::tags$div(
        class = "navbar-nav flex-row order-md-last",
        ...
      )
    )
  )
}

peskas_logo <- function() {
  htmltools::tags$div(
    htmltools::tags$span(
      class = "text-blue logo",
      style = "font-weight: bolder; display: inline-block; vertical-align: middle;",
      "PESKAS™"
    ),
    htmltools::tags$img(src = "www/tl.svg", width = "30", height = "20", style = "display: inline-block; vertical-align: middle; margin-right: 5px;")
  )
}


version_flex <- function(heading = "Heading",
                         subheading = "subheading") {
  htmltools::tags$div(
    class = "nav-item d-none d-md-flex me-3",
    htmltools::tags$span(heading),
    htmltools::tags$small(
      class = "text-muted",
      subheading
    )
  )
}
