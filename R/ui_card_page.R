page_cards <- function(...) {
  tags$div(
    class = "page-body",
    tags$div(
      class = "container-xl",
      tags$div(
        class = "row row-deck row-cards",
        ...
      )
    )
  )
}
