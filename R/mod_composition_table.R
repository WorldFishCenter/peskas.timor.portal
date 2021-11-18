#' composition_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_composition_table_ui <- function(id, ...){

  ns <- NS(id)
  tagList(
    table_card(
      # As an html output so we can tweak the alignment reactively
      table = htmlOutput(ns("t")),
      # dropdown = s,
      footer = "* All values in metric tonnes. Totals only include data after April 2018.",
      ...
    )

  )
}

#' composition_table Server Functions
#'
#' @noRd
mod_composition_table_server <- function(id, var = "catch"){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    output$t <- renderUI({

      var_info <- get_var_info(var)

      multiplier <- var_info[[var]]$multiplier
      format <- var_info[[var]]$format
      x <- peskas.timor.portal::taxa_aggregated$year[year >= 2018]
      x <- x[, (var) := get(var) * multiplier]
      x <- x[, (var) := d3.format::d3_format(format)(get(var))]
      x <- x[grouped_taxa %in% peskas.timor.portal::pars$taxa$to_display]
      x <- x[, grouped_taxa := factor(grouped_taxa, peskas.timor.portal::pars$taxa$to_display)]
      x <- dcast(x, grouped_taxa ~year, value.var = var)
      x <- merge(x[order(grouped_taxa)], peskas.timor.portal::taxa_names)
      x <- setcolorder(x, c("grouped_taxa_names", "grouped_taxa"))
      table <- setnames(x, old = c("grouped_taxa", "grouped_taxa_names"), new = c("code", "name"))
      alignment <- c("l", rep("r", ncol(table) - 1))
      alignment <- paste(alignment, collapse = "")
      output$table <- renderTable(table, spacing = "m", width = "100%",
                                  align = alignment,
                                  na = "–",
                                  class = "table-responsive")
      tableOutput(ns('table'))
    })

  })
}

## To be copied in the UI
# mod_composition_table_ui("composition_table_1")

## To be copied in the server
# mod_composition_table_server("composition_table_1")
