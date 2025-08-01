#' composition_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_table_react_ui <- function(id, ...) {
  ns <- NS(id)
  uiOutput(ns("o"))
}


#' home_table Server Functions
#'
#' @noRd
mod_home_table_server <- function(id, color_pal = NULL, i18n_r = reactive(list(t = function(x) x)), municipal_data = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    make_color_pal <- function(colors, bias = 1) {
      get_color <- grDevices::colorRamp(colors, bias = bias)
      function(x) grDevices::rgb(get_color(x), maxColorValue = 255)
    }

    good_color <- make_color_pal(color_pal, bias = 2)
    
    # Cache the heavy computation with validation and safety checks
    municipal_summary <- safe_reactive({
      req(municipal_data)
      
      data_source <- municipal_data
      
      tab <- data_source %>%
        dplyr::group_by(region) %>%
        dplyr::summarise(
          landing_revenue = stats::median(landing_revenue, na.rm = TRUE),
          landing_weight = stats::median(landing_weight, na.rm = TRUE),
          n_landings_per_boat = stats::median(n_landings_per_boat, na.rm = TRUE),
          revenue = sum(revenue, na.rm = TRUE) / 1000000,
          catch = sum(catch, na.rm = TRUE) / 1000,
          price_kg = mean(price_kg, na.rm = TRUE)
        ) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ round(., 2)))
      
      return(tab)
    }, 
    validators = list(
      validate_data_frame(required_cols = c("region", "landing_revenue", "catch"), min_rows = 1)
    ),
    fallback_value = data.frame(
      region = "No Data",
      landing_revenue = 0,
      landing_weight = 0,
      n_landings_per_boat = 0,
      revenue = 0,
      catch = 0,
      price_kg = 0
    ),
    label = "Municipal summary") %>% 
    bindCache("municipal_summary")

    output$t <- reactable::renderReactable({
      tab <- municipal_summary()
      
      if (nrow(tab) == 0) {
        return(reactable::reactable(data.frame(Message = "No data available")))
      }
      
      # Optimize data for display
      tab <- optimize_dataframe(tab, precision = 2, max_rows = 50)

      tbl <-
        reactable::reactable(
          tab,
          theme = reactablefmtr::fivethirtyeight(centered = TRUE),
          pagination = FALSE,
          compact = FALSE,
          borderless = FALSE,
          striped = FALSE,
          fullWidth = TRUE,
          sortable = TRUE,
          defaultSorted = "region",
          defaultColDef = reactable::colDef(
            align = "center",
            minWidth = 100
          ),
            columns = list(
              region = reactable::colDef(
                name = "Municipality",
                minWidth = 140,
                align = "center"
              ),
              landing_revenue = reactable::colDef(
                name = "Revenue per trip",
                style = function(value) {
                  normalized <- (value - min(tab$landing_revenue)) / (max(tab$landing_revenue) - min(tab$landing_revenue))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {
                  paste0("$", value)
                }
              ),
              n_landings_per_boat = reactable::colDef(
                name = "Landings per boat",
                style = function(value) {
                  normalized <- (value - min(tab$n_landings_per_boat)) / (max(tab$n_landings_per_boat) - min(tab$n_landings_per_boat))
                  color <- good_color(normalized)
                  list(background = color)
                }
              ),
              landing_weight = reactable::colDef(
                name = "Catch per trip",
                style = function(value) {
                  normalized <- (value - min(tab$landing_weight)) / (max(tab$landing_weight) - min(tab$landing_weight))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {
                  paste0(value, " kg")
                }
              ),
              revenue = reactable::colDef(
                name = "Total revenue",
                format = reactable::colFormat(separators = TRUE),
                style = function(value) {
                  normalized <- (value - min(tab$revenue)) / (max(tab$revenue) - min(tab$revenue))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {
                  paste0("$", value, " M")
                }
              ),
              catch = reactable::colDef(
                name = "Total catch",
                format = reactable::colFormat(separators = TRUE),
                style = function(value) {
                  normalized <- (value - min(tab$catch)) / (max(tab$catch) - min(tab$catch))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {
                  paste0(value, " t")
                }
              ),
              price_kg = reactable::colDef(
                name = "Price per kg",
                style = function(value) {
                  normalized <- (value - min(tab$price_kg)) / (max(tab$price_kg) - min(tab$price_kg))
                  color <- good_color(normalized)
                  list(background = color)
                },
                cell = function(value) {
                  paste0("$", value)
                }
              )
            )
          )
      tbl
    })

    output$o <- renderUI({
      tagList(
        div(
          class = "title",
          h2(p(i18n_r()$t(pars$home$table$title), style = "color:#666a70")),
          p(i18n_r()$t(pars$home$table$caption), style = "color:#666a70")
        ),
        reactable::reactableOutput(ns("t"), width = "100%")
      )
    })
  })
}

## To be copied in the UI
# mod_home_table_ui("composition_table_1")

## To be copied in the server
# mod_home_table_server("composition_table_1")
