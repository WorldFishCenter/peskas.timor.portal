#' Global error boundary system for robust error handling
#'
#' @description System for catching and handling errors gracefully across the application
#' @importFrom shiny showNotification observe req
#' @importFrom logger log_error log_warn log_info

#' Global error handler for the application
#' @param session Shiny session object
#' @export
setup_global_error_handler <- function(session) {
  # Set global error handler
  old_error_handler <- getOption("shiny.error")

  options(shiny.error = function() {
    error_info <- geterrmessage()
    logger::log_error("Global error: {error_info}")

    # Show user-friendly notification
    showNotification(
      "Something went wrong. The page will try to recover automatically.",
      type = "warning",
      duration = 5
    )

    # Try to recover by refreshing critical data
    session$sendCustomMessage("peskas-error-recovery", list(
      message = "Attempting automatic recovery...",
      timestamp = Sys.time()
    ))

    # Call original handler if it exists
    if (!is.null(old_error_handler)) {
      tryCatch(old_error_handler(), error = function(e) NULL)
    }
  })

  # Cleanup on session end
  session$onSessionEnded(function() {
    options(shiny.error = old_error_handler)
  })
}

#' Create an error boundary component
#' @param ui_content UI content to wrap
#' @param fallback_ui Fallback UI to show on error
#' @param error_handler Custom error handler function
#' @param label Label for logging
#' @export
error_boundary <- function(ui_content, fallback_ui = NULL, error_handler = NULL, label = "Error boundary") {
  if (is.null(fallback_ui)) {
    fallback_ui <- tags$div(
      class = "alert alert-warning",
      tags$h4("Content temporarily unavailable"),
      tags$p("This section is experiencing issues and will be restored shortly."),
      tags$small("Error ID: ", format(Sys.time(), "%Y%m%d-%H%M%S"))
    )
  }

  # Wrap UI content with error handling
  tryCatch(
    {
      ui_content
    },
    error = function(e) {
      logger::log_error("{label}: {e$message}")

      if (!is.null(error_handler)) {
        tryCatch(error_handler(e), error = function(handler_error) {
          logger::log_error("Error handler failed: {handler_error$message}")
        })
      }

      fallback_ui
    }
  )
}

#' Safe module server wrapper
#' @param module_server Module server function
#' @param id Module ID
#' @param ... Additional arguments to pass to module server
#' @param label Label for logging
#' @export
safe_module_server <- function(module_server, id, ..., label = paste("Module", id)) {
  tryCatch(
    {
      module_server(id, ...)
    },
    error = function(e) {
      logger::log_error("{label} failed to initialize: {e$message}")

      # Return a minimal working module server
      moduleServer(id, function(input, output, session) {
        output$error_message <- renderUI({
          tags$div(
            class = "alert alert-danger",
            tags$h5("Module Error"),
            tags$p("This module failed to load properly."),
            tags$small("Module ID: ", id, " | Error: ", e$message)
          )
        })
      })
    }
  )
}

#' Resilient reactive expression
#' @param expr Reactive expression
#' @param fallback_value Value to return on error
#' @param retry_attempts Number of retry attempts
#' @param retry_delay_ms Delay between retries in milliseconds
#' @param label Label for logging
#' @export
resilient_reactive <- function(expr, fallback_value = NULL, retry_attempts = 3, retry_delay_ms = 1000, label = "Resilient reactive") {
  attempt_count <- reactiveVal(0)
  last_error <- reactiveVal(NULL)

  reactive({
    current_attempt <- attempt_count() + 1
    attempt_count(current_attempt)

    tryCatch(
      {
        result <- expr
        # Reset attempt count on success
        if (current_attempt > 1) {
          logger::log_info("{label}: Recovered after {current_attempt} attempts")
          attempt_count(0)
        }
        return(result)
      },
      error = function(e) {
        last_error(e)
        logger::log_warn("{label}: Attempt {current_attempt} failed: {e$message}")

        if (current_attempt < retry_attempts) {
          # Schedule retry
          later::later(function() {
            attempt_count(current_attempt)
          }, delay = retry_delay_ms / 1000)

          return(fallback_value)
        } else {
          logger::log_error("{label}: All {retry_attempts} attempts failed")
          attempt_count(0) # Reset for future attempts
          return(fallback_value)
        }
      }
    )
  })
}

#' Create a health check system
#' @param checks List of health check functions
#' @param check_interval_ms Interval between health checks
#' @export
setup_health_monitor <- function(checks, check_interval_ms = 30000) {
  health_status <- reactiveVal(list())

  # Run health checks periodically
  observe({
    invalidateLater(check_interval_ms)

    current_status <- list()
    for (name in names(checks)) {
      current_status[[name]] <- tryCatch(
        {
          check_result <- checks[[name]]()
          list(status = "healthy", result = check_result, timestamp = Sys.time())
        },
        error = function(e) {
          logger::log_warn("Health check {name} failed: {e$message}")
          list(status = "unhealthy", error = e$message, timestamp = Sys.time())
        }
      )
    }

    health_status(current_status)
  })

  return(health_status)
}

#' Add JavaScript error recovery script
#' @export
error_recovery_js <- function() {
  tags$script("
    // Listen for error recovery messages
    Shiny.addCustomMessageHandler('peskas-error-recovery', function(message) {
      console.log('Error recovery initiated:', message);

      // Show recovery notification
      if (typeof Shiny !== 'undefined' && Shiny.notifications) {
        Shiny.notifications.show({
          message: message.message,
          type: 'message',
          duration: 3
        });
      }

      // Attempt to refresh reactive contexts
      setTimeout(function() {
        if (window.location.hash) {
          // Trigger reactive updates by changing hash
          var currentHash = window.location.hash;
          window.location.hash = '';
          setTimeout(function() {
            window.location.hash = currentHash;
          }, 100);
        }
      }, 1000);
    });

    // Global JavaScript error handler
    window.addEventListener('error', function(event) {
      console.error('JavaScript error:', event.error);

      // Report to Shiny if available
      if (typeof Shiny !== 'undefined' && Shiny.setInputValue) {
        Shiny.setInputValue('js_error', {
          message: event.error.message,
          filename: event.filename,
          lineno: event.lineno,
          timestamp: new Date().toISOString()
        }, {priority: 'event'});
      }
    });
  ")
}
