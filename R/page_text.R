page_text <- function(content = markdown("Page content")){
  tags$div(
    class = "page-body",
    tags$div(
      class = "container-xl",
      tags$div(
        class = "row justify-content-center",
        tags$div(
          class = "col-lg-10 col-xl-9",
          tags$div(
            class = "card card-lg",
            tags$div(
              class = "card-body markdown",
              content
            )
          )
        )
      )
    )
  )
}
