#' Performance monitoring utilities
#'
#' @description Utilities for monitoring and logging performance metrics
#' @importFrom shiny observeEvent req
#' @importFrom logger log_info log_warn log_error

#' Time a function execution
#' @param expr Expression to time
#' @param label Label for logging
#' @export
time_execution <- function(expr, label = "Operation") {
  start_time <- Sys.time()
  tryCatch(
    {
      result <- expr
      end_time <- Sys.time()
      duration <- as.numeric(difftime(end_time, start_time, units = "secs"))

      if (duration > 2) {
        logger::log_warn("{label} took {round(duration, 2)} seconds (slow)")
      } else {
        logger::log_info("{label} completed in {round(duration, 3)} seconds")
      }

      return(result)
    },
    error = function(e) {
      logger::log_error("{label} failed: {e$message}")
      stop(e)
    }
  )
}

#' Monitor reactive performance
#' @param reactive_expr Reactive expression
#' @param label Label for monitoring
#' @export
monitor_reactive <- function(reactive_expr, label = "Reactive") {
  reactive({
    time_execution(
      {
        reactive_expr()
      },
      label
    )
  })
}

#' Log memory usage
#' @param label Context label
#' @export
log_memory_usage <- function(label = "Memory check") {
  mem_info <- gc(verbose = FALSE)
  used_mb <- sum(mem_info[, 2]) / 1024^2
  logger::log_info("{label}: {round(used_mb, 1)} MB memory used")
}

#' Initialize performance monitoring
#' @param session Shiny session object
#' @export
init_performance_monitoring <- function(session) {
  # Log session start
  logger::log_info("Shiny session started")
  log_memory_usage("Session start")

  # Monitor for session end
  session$onSessionEnded(function() {
    logger::log_info("Shiny session ended")
    log_memory_usage("Session end")
  })
}

#' Create a performance-aware reactive
#' @param expr Reactive expression
#' @param label Label for logging
#' @param threshold_seconds Warn if execution takes longer than this
#' @export
perf_reactive <- function(expr, label = "Reactive", threshold_seconds = 1) {
  reactive({
    start_time <- Sys.time()
    result <- expr
    duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

    if (duration > threshold_seconds) {
      logger::log_warn("{label} reactive took {round(duration, 2)}s (threshold: {threshold_seconds}s)")
    }

    result
  })
}
