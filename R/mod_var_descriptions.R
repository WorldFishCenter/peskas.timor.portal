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
        accordion_item_ui(
          id = ns(paste0("accordion", "-", names(x))),
          id_parent = ns("accordion"),
          heading = x[[1]]$short_name,
          content = x[[1]]$info
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
