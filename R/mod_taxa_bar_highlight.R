#' taxa_bar_highlight UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_taxa_bar_highlight_ui <- function(id, heading = NULL, apex_height = "20rem", ...){
  ns <- NS(id)

  # if (is.null(years)) {
    years <- seq(as.numeric(format(Sys.Date(), "%Y")), "2018")
  # }

  s <- selectInput(ns("y"),
                   label = "",
                   choices = years,
                   selectize = FALSE,
                   width = "auto")

  s$children[[2]]$children[[1]] <-
    htmltools::tagAppendAttributes(s$children[[2]]$children[[1]],
                                   class = "form-select")


  tagList(
    highlight_card(
      id = id,
      heading = heading,
      top_right = s,
      in_body = tags$div(
        class = "mt-0",
        apexcharter::apexchartOutput(ns("c"), height = apex_height)),
      ...
    )
  )
}

#' taxa_bar_highlight Server Functions
#'
#' @noRd
mod_taxa_bar_highlight_server <- function(id, var, colors){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    plot_data <- reactive({

      from <- as.Date(paste0(input$y, "-01-01"))
      to <- as.Date(paste0(input$y, "-12-01"))
      x <- peskas.timor.portal::taxa_aggregated$month[date_bin_start >= from & date_bin_start <= to]
      x <- x[grouped_taxa %in% pars$taxa$to_display]
      x <- x[, .(catch = sum(catch)), by = "grouped_taxa"]
      x <- x[, grouped_taxa := factor(grouped_taxa, pars$taxa$to_display)]
      merge(x[order(grouped_taxa)], peskas.timor.portal::taxa_names)
    })

    output$c <- apexcharter::renderApexchart({

      d <- get_series_info(var, n = 2)

      data <- plot_data()

      plot_horizontal_barplot(
        x_categories = data$grouped_taxa_names,
        series = list(
          name = d$series[[1]]$series_name,
          data = data$catch * d$series[[1]]$series_multiplier),
        y_formatter = V8::JS("function(x) {return x}"),
        x_formatter = apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix),
        colors = colors
      )
    })

  })
}

## To be copied in the UI
# mod_taxa_bar_highlight_ui("taxa_bar_highlight_1")

## To be copied in the server
# mod_taxa_bar_highlight_server("taxa_bar_highlight_1")


