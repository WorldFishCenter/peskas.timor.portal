accordion_ui <- function(id, ...) {
  tags$div(
    class = "accordion",
    id = id,
    ...
  )
}

accordion_item_ui <- function(id, id_parent, heading = "Accordion heading", content = "Acordion content", expanded = FALSE) {
  collapse_class <- "accordion-collapse collapse"
  button_class <- "accordion-button collapsed"
  aria_expanded <- "false"

  if (expanded) {
    aria_expanded <- "true"
    collapse_class <- paste(collapse_class, "show")
    button_class <- "accordion_button"
  }

  tags$div(
    class = "accordion-item",
    tags$h2(
      class = "accordion-header",
      id = paste0(id, "-heading"),
      tags$button(
        class = button_class,
        type = "button",
        `data-bs-toggle` = "collapse",
        `data-bs-target` = paste0("#", id, "-collapse"),
        `aria-expanded` = aria_expanded,
        heading
      )
    ),
    tags$div(
      id = paste0(id, "-collapse"),
      class = collapse_class,
      `data-bs-parent` = paste0("#", id_parent),
      tags$div(
        class = "accordion-body pt-0",
        content
      )
    )
  )
}
