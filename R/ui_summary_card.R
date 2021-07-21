summary_card <- function(id = "",
                         heading = "Card heading",
                         subheader = "Card subheader",
                         annotation = NULL,
                         top_right_element = NULL,
                         in_body = NULL,
                         off_body = NULL,
                         card_class = "col-sm-6 col-lg-3"){
  tags$div(
    id = id,
    class = card_class,
    tags$div(
      class = "card",
      tags$div(
        class = "card-body pb-0",
        tags$div(
          class = "d-flex align-items-center",
          tags$div(
            class = "subheader",
            subheader
          ),
          tags$div(
            class = "ms-auto lh-1",
            top_right_element
          )
        ),
        tags$div(
          class = "d-flex align-items-baseline",
          tags$div(
            class = "h1 mb-0",
            heading
          ),
          tags$div(
            class = "me-auto",
            annotation
          )
        ),
        tags$div(
          class = "in-body",
          in_body
        )
      ),
      tags$div(
        class = 'off-body',
        off_body
      )
    )
  )
}


card_dropdown <- function(){
  tags$div(
    class = "dropdown",
    tags$a(
      class = "dropdown-toggle text-muted",
      href = "#",
      `data-bs-toggle` = "dropdown",
      `aria-haspopup` = "true",
      `aria-expanded` = "false",
      "Last 7 days"
    ),
    tags$div(
      class = "dropdown-menu dropdown-menu-end",
      style = NA,
      tags$a(
        class = "dropdown-item active",
        href = "#",
        "Last 7 days"
      ),
      tags$a(
        class = "dropdown-item",
        href = "#",
        "Last 30 days"
      ),
      tags$a(
        class = "dropdown-item",
        href = "#",
        "Last 3 months"
      )
    )
  )
}

unit_annotation <- function(unit = NULL){
  div(
    class = "text-muted mb-1",
    unit
  )
}

trend_annotation <- function(magnitude = "0%", direction = c("none", "up","down")){

  icon <- switch(
    direction[1],
    "none" = icon_trend_none(),
    "up" = icon_trend_up(),
    "down" = icon_trend_down(),
    NULL
  )

  colour_class <- switch(
    direction[1],
    "none" = "text-yellow",
    "up" = "text-green",
    "down" = "text-red",
    "text-muted"
  )

  tags$span(
    class = paste(colour_class,"ms-2 d-inline-flex align-items-center lh-1"),
    magnitude,
    icon
  )
}
