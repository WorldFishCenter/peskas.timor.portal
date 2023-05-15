#' taxa_bar_highlight UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_taxa_bar_highlight_ui <- function(id, heading = NULL, apex_height = "20rem", ...) {
  ns <- NS(id)

  # if (is.null(years)) {
  years <- seq(as.numeric(format(Sys.Date(), "%Y")), "2018")
  # }

  s <- selectInput(ns("y"),
    label = "",
    choices = years,
    selectize = FALSE,
    width = "auto"
  )

  regions <- list("Municipality" = sort(unique(peskas.timor.portal::municipal_aggregated$region)))

  r <- selectInput(ns("r"),
    label = "",
    choices = c("National", regions),
    selectize = FALSE,
    width = "auto"
  )

  s$children[[2]]$children[[1]] <-
    htmltools::tagAppendAttributes(s$children[[2]]$children[[1]],
      class = "form-select"
    )

  r$children[[2]]$children[[1]] <-
    htmltools::tagAppendAttributes(r$children[[2]]$children[[1]],
      class = "form-select"
    )


  tagList(
    highlight_card(
      id = id,
      heading = heading,
      top_right = list(s, r),
      in_body = tags$div(
        class = "mt-0",
        uiOutput(ns("c"))
        # apexcharter::apexchartOutput(ns("c"), height = apex_height)
      ),
      ...
    )
  )
}

#' taxa_bar_highlight Server Functions
#'
#' @noRd
mod_taxa_bar_highlight_server <- function(id, var, colors, i18n_r = reactive(list(t = function(x) x))) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    plot_data <- reactive({
      dat <-
        if (input$r == "National") {
          peskas.timor.portal::taxa_aggregated$month
        } else {
          peskas.timor.portal::municipal_taxa[region %in% input$r]
        }

      from <- as.Date(paste0(input$y, "-01-01"))
      to <- as.Date(paste0(input$y, "-12-01"))
      x <- dat[date_bin_start >= from & date_bin_start <= to]
      x <- x[grouped_taxa %in% peskas.timor.portal::taxa_names$grouped_taxa]
      x <- x[, .(catch = sum(catch)), by = "grouped_taxa"]
      missing_taxa <- setdiff(peskas.timor.portal::taxa_names$grouped_taxa, x$grouped_taxa)
      if (length(missing_taxa) > 0) {
        new_rows <- data.table::data.table(
          grouped_taxa = missing_taxa,
          catch = rep(0, length(missing_taxa))
        )
        x <- rbind(x, new_rows)
      }
      x <- x[, grouped_taxa := factor(grouped_taxa, peskas.timor.portal::taxa_names$grouped_taxa)]
      merge(x[order(grouped_taxa)], peskas.timor.portal::taxa_names)
    })

    output$c <- renderUI({
      d <- get_series_info(var, n = 2)
      data <- plot_data()
      taxa_names <- i18n_r()$t(plot_data()$grouped_taxa_names)

      output$char <- apexcharter::renderApexchart({
        plot_horizontal_barplot(
          x_categories = taxa_names,
          series = list(
            name = d$series[[1]]$series_name,
            data = data$catch * d$series[[1]]$series_multiplier
          ),
          y_formatter = V8::JS("function(x) {return x}"),
          x_formatter = apexcharter::format_num(d$series[[1]]$series_format, suffix = d$series[[1]]$series_suffix),
          colors = colors
        )
      })
    })
    apexcharter::apexchartOutput(ns("char"), height = "20rem")
  })
}


## To be copied in the UI
# mod_taxa_bar_highlight_ui("taxa_bar_highlight_1")

## To be copied in the server
# mod_taxa_bar_highlight_server("taxa_bar_highlight_1")
