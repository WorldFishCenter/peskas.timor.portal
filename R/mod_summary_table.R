#' summary_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_summary_table_ui <- function(id, ...){
  ns <- NS(id)
  tables <- get_yearly_tables("revenue")
  years <- names(tables)

  s <- selectInput(ns("d"),
                   label = "",
                   choices = years,
                   selectize = FALSE,
                   width = "auto")

  s$children[[2]]$children[[1]] <-
    htmltools::tagAppendAttributes(s$children[[2]]$children[[1]],
                                   class = "form-select")

  tagList(
    table_card(
      table = tableOutput(ns("t")),
      dropdown = s,
      ...
    )

  )
}

#' summary_table Server Functions
#'
#' @noRd
mod_summary_table_server <- function(id, var, format_fun = I){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    tables <- get_yearly_tables(var)

    output$t <- renderTable({
      table <- tables[[input$d]]
      table[]
    }, spacing = "m", width = "100%")

  })
}

mod_summary_table_app <- function(){
  ui <- tabler_page(
    mod_summary_table_ui(id = "i")
  )
  server <- function(input, output, session) {
    mod_summary_table_server("i")
  }
  shinyApp(ui, server)
}


## To be copied in the UI
# mod_summary_table_ui("summary_table_ui_1")

## To be copied in the server
# mod_summary_table_server("summary_table_ui_1")

table_card <- function(heading = "Heading", card_class = "col-lg-6", table = NULL, dropdown = NULL){
  tags$div(
    class = card_class,
    tags$div(
      class = "card",
      tags$div(
        class = "card-header",
        tags$div(
          tags$h3(
            class = "card-title",
            heading
          )
        ),
        tags$div(
          class = "ms-auto lh-1",
          dropdown
        )

      ),
      tags$div(
        class = "card-table table-responsive",
        table
      )
    )
  )
}


get_yearly_tables <- function(var, digits = 2){
  period <- "month"
  data <- aggregated[[period]]
  data <- data[order(-date_bin_start),]
  data <- data[!is.na(date_bin_start), ]
  data <- data[, period := month][]
  data <- data[, (var) := lapply(.SD, signif, digits = digits), .SDcols = var]
  data <- split(data, by = "year")
  data <- lapply(data, function(x) x[, c(..period, ..var)])
  data <- lapply(data, function(x) x[complete.cases(x), ])
  data

}
