#' var_descriptions UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_var_descriptions_ui <- function(id, heading, subheading = NULL, intro = ""){
  ns <- NS(id)
  tagList(
    text_card_ui(
      id = id,
      heading = heading,
      subheading = subheading,
      intro,
      htmlOutput(ns("vars"))
    )

  )
}

#' var_descriptions Server Functions
#'
#' @noRd
mod_var_descriptions_server <- function(id, vars){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$vars <- renderUI({

      info <- lapply(vars, get_var_info)
      accordion_items <- lapply(info, function(x) {
        bg <- get_bg_quality(x[[1]]$quality)

        accordion_item_ui(
          id = ns(paste0("accordion", "-", names(x))),
          id_parent = ns("accordion"),
          heading =
            tagList(
              tags$span(
                class = paste("badge badge-pill me-3", bg$normal)
              ),
              x[[1]]$short_name
            ),
          content = tagList(
            tags$p(
              class = "",
              x[[1]]$info),
            tags$p(
              class = paste("badge mb-0", bg$light),
              icon_check(),
              "Data quality:",
              get_quality_text(x[[1]]$quality)),

          )
        )
      })

      tagList(
        accordion_ui(
          id = ns("accordion"),
          accordion_items
        )
      )
    })

  })
}

get_bg_quality <- function(x){
  if (is.null(x)) {
    bg <- "secondary"
  } else {
    bg <- switch(x,
      low = "red",
      medium = "yellow",
      high = "green",
      "cyan"
    )
  }
  list(
    normal = paste("bg", bg, sep = "-"),
    light = paste("bg", bg, "lt", sep = "-")
  )
}

get_quality_text <- function(x){
  if (!any(x %in% c("low", "medium","high"))) return("Not assessed")
  x
}

mod_var_descriptions_app <- function(){
  ui <- tabler_page(
    mod_var_descriptions_ui(id = "i", "About this data", intro = markdown("Below some info"))
  )
  server <- function(input, output, session) {
    mod_var_descriptions_server("i", c("revenue", "n_landings"))
  }
  shinyApp(ui, server)
}

text_ui <- function(heading = "", text = ""){
  tagList(
    tags$h4(
      heading
    ),
    tags$p(
      text
    )
  )
}

text_card_ui <- function(id = "", heading = "Card heading", subheading = "Card subheading", ...){
  tags$div(
    class = "card",
    id = id,
    tags$div(
      class = "card-body markdown",
      tags$h3(
        class = "card-title mb-0",
        heading
      ),
      tags$div(
        class = "card-subtitle my-0",
        subheading
      ),
      tags$div(
        class = "mt-3",
        tagList(
          ...
        )
      )
    )
  )
}

get_var_info <- function(var){
  peskas.timor.portal::var_dictionary[var]
}
