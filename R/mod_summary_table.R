#' summary_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_summary_table_ui <- function(id, years = NULL, ...){

  ns <- NS(id)
  if (is.null(years)) {
    years <- seq(as.numeric(format(Sys.Date(), "%Y")), "2018")
  }

  s <- selectInput(ns("y"),
                   label = "",
                   choices = years,
                   selectize = FALSE,
                   width = "auto")

  s$children[[2]]$children[[1]] <-
    htmltools::tagAppendAttributes(s$children[[2]]$children[[1]],
                                   class = "form-select")

  tagList(
    table_card(
      # As an html output so we can tweak the alignment reactively
      table = htmlOutput(ns("t")),
      dropdown = s,
      footer = textOutput(ns("f"), inline = T),
      ...
    )

  )
}

#' summary_table Server Functions
#'
#' @noRd
mod_summary_table_server <- function(id, vars, period = "month", format_fun = I, i18n_r = reactive(list(t = function(x) x))){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    info <- reactive(get_series_info(vars, period, year = input$y))

    table <- reactive({
      info <- info()
      data_columns <- lapply(info$series, function(x) {
        vals <- data.table(d3.format::d3.format(x$series_format, suffix = x$series_suffix)(x$series_value * x$series_multiplier))
        names(vals) <- i18n_r()$t(x$series_name)
        vals
      })
      if (period == "month"){
        period_col <- data.table(period = format(as.Date(info$x_datetime), "%B"))
      } else {
        period_col <- data.table(period = info$x_categories)
      }
      names(period_col)[1] <- i18n_r()$t(names(period_col)[1])
      cbind(period_col, Reduce(cbind, data_columns))
    })

    output$t <- renderUI({
      table <- table()
      alignment <- c("l", rep("r", ncol(table) - 1))
      alignment <- paste(alignment, collapse = "")
      output$table <- renderTable(table, spacing = "m", width = "100%",
                                  align = alignment,
                                  na = "–",
                                  class = "table-responsive")
      tableOutput(ns('table'))
      })

    output$f <- renderText({
      info <- info()
      total <- sum(info$series[[1]]$series_value, na.rm = TRUE)
      text <- paste0(info$series[[1]]$series_name)
      paste(i18n_r()$t(text), ":", d3.format::d3.format(info$series[[1]]$series_format, suffix = info$series[[1]]$series_suffix)(total * info$series[[1]]$series_multiplier))
    })


  })
}

mod_summary_table_app <- function(){
  ui <- tabler_page(
    mod_summary_table_ui(id = "i")
  )
  server <- function(input, output, session) {
    mod_summary_table_server("i", c("revenue", "n_boats"))
  }
  shinyApp(ui, server)
}



table_card <- function(heading = "Heading", card_class = "col-lg-6", table = NULL, dropdown = NULL, footer = NULL){
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
      ),
      tags$div(
        class = "card-footer",
        tags$div(
          class = "d-flex justify-content-end",
          footer
        )
      )
    )
  )
}

