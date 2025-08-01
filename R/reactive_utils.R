#' Reactive utilities for safe and performant reactive programming
#'
#' @description Utilities for creating safer and more performant reactive expressions
#' @importFrom shiny reactive req validate need
#' @importFrom logger log_warn log_error

#' Create a safe reactive that validates inputs
#' @param expr Reactive expression
#' @param validators List of validation functions
#' @param fallback_value Value to return if validation fails
#' @param label Label for logging
#' @export
safe_reactive <- function(expr, validators = list(), fallback_value = NULL, label = "Safe reactive") {
  reactive({
    tryCatch({
      # Evaluate the expression
      result <- eval(substitute(expr), parent.frame())
      
      # Run validators
      for (validator in validators) {
        if (!validator(result)) {
          logger::log_warn("{label}: Validation failed, returning fallback")
          return(fallback_value)
        }
      }
      
      return(result)
    }, error = function(e) {
      logger::log_error("{label} failed: {e$message}")
      return(fallback_value)
    })
  })
}

#' Validate that data frame has required columns and rows
#' @param required_cols Required column names
#' @param min_rows Minimum number of rows
#' @export
validate_data_frame <- function(required_cols = character(0), min_rows = 1) {
  function(df) {
    if (!is.data.frame(df)) return(FALSE)
    if (nrow(df) < min_rows) return(FALSE)
    if (length(required_cols) > 0 && !all(required_cols %in% names(df))) return(FALSE)
    return(TRUE)
  }
}

#' Validate numeric data
#' @param min_val Minimum value
#' @param max_val Maximum value
#' @param allow_na Allow NA values
#' @export
validate_numeric <- function(min_val = -Inf, max_val = Inf, allow_na = FALSE) {
  function(x) {
    if (!is.numeric(x)) return(FALSE)
    if (!allow_na && any(is.na(x))) return(FALSE)
    if (any(x < min_val, na.rm = TRUE)) return(FALSE)
    if (any(x > max_val, na.rm = TRUE)) return(FALSE)
    return(TRUE)
  }
}

#' Create a cached reactive with automatic invalidation
#' @param expr Reactive expression
#' @param cache_key Cache key
#' @param invalidate_after_seconds Auto-invalidate after this many seconds
#' @param label Label for logging
#' @export
cached_reactive <- function(expr, cache_key, invalidate_after_seconds = 300, label = "Cached reactive") {
  cache_time <- reactiveVal(Sys.time())
  
  reactive({
    current_time <- Sys.time()
    if (difftime(current_time, cache_time(), units = "secs") > invalidate_after_seconds) {
      logger::log_info("{label}: Cache expired, refreshing")
      cache_time(current_time)
    }
    
    expr
  }) %>% bindCache(cache_key, cache_time())
}

#' Create a throttled reactive that limits update frequency
#' @param expr Reactive expression
#' @param millis Throttle interval in milliseconds
#' @param label Label for logging
#' @export
throttled_reactive <- function(expr, millis = 1000, label = "Throttled reactive") {
  reactive({
    expr
  }) %>% throttle(millis)
}

#' Batch multiple reactive updates
#' @param ... Named reactive expressions
#' @param batch_size Number of updates to batch together
#' @export
batch_reactives <- function(..., batch_size = 3) {
  reactives <- list(...)
  
  # Create a trigger that fires when enough updates accumulate
  batch_trigger <- reactiveVal(0)
  
  observe({
    # Monitor all reactives
    lapply(reactives, function(r) r())
    
    # Increment batch counter
    current_count <- isolate(batch_trigger()) + 1
    if (current_count >= batch_size) {
      batch_trigger(0)  # Reset counter
    } else {
      batch_trigger(current_count)
    }
  })
  
  return(batch_trigger)
}

#' Create a conditional reactive that only updates when condition is met
#' @param expr Reactive expression
#' @param condition_expr Condition expression (reactive)
#' @param label Label for logging
#' @export
conditional_reactive <- function(expr, condition_expr, label = "Conditional reactive") {
  reactive({
    if (condition_expr()) {
      logger::log_info("{label}: Condition met, updating")
      expr
    } else {
      logger::log_info("{label}: Condition not met, skipping update")
      NULL
    }
  })
}