
footer_panel <- function(right_side_elements = tagList(), left_side_elements = tagList()) {
  tags$footer(
    class = "footer footer-transparent d-print-none",
    tags$div(
      class = "container",
      tags$div(
        class = "row text-center align-items-center flex-row-reverse",
        tags$div(
          class = "col-lg-auto ms-lg-auto",
          tags$ul(
            class = "list-inline list-inline-dots mb-0",
            right_side_elements
          )
        ),
        tags$div(
          class = "col-12 col-lg-auto mt-3 mt-lg-0",
          tags$ul(
            class = "list-inline list-inline-dots mb-0",
            left_side_elements
          )
        )
      )
    )
  )
}

#' Creates a inline list item with a link
#'
#' Te be used in elements like the footer
#'
#' @return a shiny tag "li" element
#'
inline_li_link <- function(content = "Link text", href = "#", target = "_blank"){
  tags$li(
    class = "list-inline-item",
    tags$a(
      href = href,
      target = target,
      class = "link-secondary",
      content
    )
  )
}



