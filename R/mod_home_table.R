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
    
    # Safe normalization function that handles NA and equal values
    safe_normalize <- function(value, values) {
      if (is.na(value) || length(values) == 0) return(0.5)
      
      min_val <- min(values, na.rm = TRUE)
      max_val <- max(values, na.rm = TRUE)
      
      # Handle case where all values are the same
      if (min_val == max_val || is.na(min_val) || is.na(max_val)) {
        return(0.5)  # Return middle of color range
      }
      
      normalized <- (value - min_val) / (max_val - min_val)
      
      # Handle any remaining NA cases
      if (is.na(normalized)) return(0.5)
      
      # Clamp to [0,1] range
      return(pmax(0, pmin(1, normalized)))
    }
    
    # Cache the heavy computation with validation and safety checks
    municipal_summary <- reactive({
      tryCatch({
        # Get reactive data value
        data_source <- municipal_data()
        
        # Handle progressive loading - return fallback if data not ready
        if (is.null(data_source)) {
          return(data.frame(
            region = "Loading...",
            landing_revenue = 0,
            landing_weight = 0,
            n_landings_per_boat = 0,
            revenue = 0,
            catch = 0,
            price_kg = 0
          ))
        }
        
        # Validate that we have data with required columns
        if (!all(c("region", "landing_revenue", "catch") %in% names(data_source))) {
          logger::log_warn("Municipal summary: Missing required columns")
          return(data.frame(
            region = "No Data",
            landing_revenue = 0,
            landing_weight = 0,
            n_landings_per_boat = 0,
            revenue = 0,
            catch = 0,
            price_kg = 0
          ))
        }
        
        tab <- data_source %>%
          dplyr::group_by(region) %>%
          dplyr::summarise(
            landing_revenue = stats::median(landing_revenue, na.rm = TRUE),
            landing_weight = stats::median(landing_weight, na.rm = TRUE),
            n_landings_per_boat = stats::median(n_landings_per_boat, na.rm = TRUE),
            revenue = sum(revenue, na.rm = TRUE) / 1000000,
            catch = sum(catch, na.rm = TRUE) / 1000,
            price_kg = mean(price_kg, na.rm = TRUE),
            .groups = 'drop'
          ) %>%
          dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ round(., 2)))
        
        return(tab)
      }, error = function(e) {
        logger::log_error("Municipal summary failed: {e$message}")
        return(data.frame(
          region = "Error",
          landing_revenue = 0,
          landing_weight = 0,
          n_landings_per_boat = 0,
          revenue = 0,
          catch = 0,
          price_kg = 0
        ))
      })
    }) %>% 
    bindCache("municipal_summary")

    output$t <- reactable::renderReactable({
      tab <- municipal_summary()
      
      if (nrow(tab) == 0) {
        return(reactable::reactable(data.frame(Message = "No data available")))
      }
      
      # Show loading state
      if (nrow(tab) == 1 && tab$region[1] == "Loading...") {
        return(reactable::reactable(
          data.frame(Status = "Loading municipal data..."),
          theme = reactablefmtr::fivethirtyeight(centered = TRUE),
          pagination = FALSE
        ))
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
                  normalized <- safe_normalize(value, tab$landing_revenue)
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
                  normalized <- safe_normalize(value, tab$n_landings_per_boat)
                  color <- good_color(normalized)
                  list(background = color)
                }
              ),
              landing_weight = reactable::colDef(
                name = "Catch per trip",
                style = function(value) {
                  normalized <- safe_normalize(value, tab$landing_weight)
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
                  normalized <- safe_normalize(value, tab$revenue)
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
                  normalized <- safe_normalize(value, tab$catch)
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
                  normalized <- safe_normalize(value, tab$price_kg)
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
