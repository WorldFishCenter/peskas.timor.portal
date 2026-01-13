#' Async processing utilities for heavy computations
#'
#' @description Utilities for offloading heavy computations to background processes
#' @importFrom promises promise
#' @importFrom future future value
#' @importFrom shiny reactiveVal observe isolate
#' @importFrom logger log_info log_error
#' @importFrom digest digest

#' Create an async reactive for heavy computations
#' @param expr Expression to compute asynchronously
#' @param initial_value Initial value while computing
#' @param label Label for logging
#' @export
async_reactive <- function(expr, initial_value = NULL, label = "Async computation") {
  result <- reactiveVal(initial_value)
  computing <- reactiveVal(FALSE)

  # Function to trigger async computation
  compute <- function() {
    if (computing()) {
      logger::log_info("{label}: Already computing, skipping")
      return()
    }

    computing(TRUE)
    logger::log_info("{label}: Starting async computation")

    future_promise <- future::future({
      expr
    }) %...>% (function(computed_result) {
      logger::log_info("{label}: Async computation completed")
      result(computed_result)
      computing(FALSE)
    }) %...!% (function(error) {
      logger::log_error("{label}: Async computation failed: {error$message}")
      computing(FALSE)
    })

    return(future_promise)
  }

  list(
    result = result,
    computing = computing,
    compute = compute
  )
}

#' Process data aggregation asynchronously
#' @param data Input data
#' @param group_vars Grouping variables
#' @param summary_vars Summary variables
#' @param label Label for logging
#' @export
async_data_aggregation <- function(data, group_vars, summary_vars, label = "Data aggregation") {
  async_reactive(
    {
      logger::log_info("{label}: Processing {nrow(data)} rows")

      result <- data %>%
        dplyr::group_by(!!!rlang::syms(group_vars)) %>%
        dplyr::summarise(
          !!!purrr::map(summary_vars, ~ rlang::expr(mean(!!rlang::sym(.x), na.rm = TRUE))),
          .groups = "drop"
        )

      logger::log_info("{label}: Aggregated to {nrow(result)} rows")
      return(result)
    },
    initial_value = data.frame(),
    label = label
  )
}

#' Create a progressive loader for heavy modules
#' @param module_loaders List of module loading functions
#' @param load_delay_ms Delay between loading each module
#' @export
progressive_module_loader <- function(module_loaders, load_delay_ms = 500) {
  loaded_modules <- reactiveVal(character(0))
  loading_progress <- reactiveVal(0)

  load_next <- function() {
    current_loaded <- isolate(loaded_modules())
    remaining <- setdiff(names(module_loaders), current_loaded)

    if (length(remaining) == 0) {
      logger::log_info("All modules loaded")
      return()
    }

    next_module <- remaining[1]
    logger::log_info("Loading module: {next_module}")

    tryCatch(
      {
        module_loaders[[next_module]]()
        loaded_modules(c(current_loaded, next_module))
        loading_progress(length(current_loaded + 1) / length(module_loaders))

        # Schedule next module load
        if (length(remaining) > 1) {
          later::later(load_next, delay = load_delay_ms / 1000)
        }
      },
      error = function(e) {
        logger::log_error("Failed to load module {next_module}: {e$message}")
      }
    )
  }

  list(
    start_loading = load_next,
    loaded_modules = loaded_modules,
    progress = loading_progress
  )
}

#' Create a background data processor
#' @param data_source Reactive data source
#' @param processing_fn Processing function
#' @param update_interval_ms How often to check for updates
#' @param label Label for logging
#' @export
background_processor <- function(data_source, processing_fn, update_interval_ms = 5000, label = "Background processor") {
  processed_data <- reactiveVal()
  last_processed <- reactiveVal(Sys.time())
  processing <- reactiveVal(FALSE)

  # Background processing loop
  observe({
    invalidateLater(update_interval_ms)

    if (processing()) {
      return()
    }

    current_data <- data_source()
    if (is.null(current_data)) {
      return()
    }

    # Check if data has changed (simple hash comparison)
    current_hash <- digest::digest(current_data)
    if (exists("last_hash") && current_hash == last_hash) {
      return()
    }

    processing(TRUE)
    logger::log_info("{label}: Starting background processing")

    future::future({
      processing_fn(current_data)
    }) %...>% (function(result) {
      processed_data(result)
      processing(FALSE)
      last_processed(Sys.time())
      last_hash <<- current_hash
      logger::log_info("{label}: Background processing completed")
    }) %...!% (function(error) {
      logger::log_error("{label}: Background processing failed: {error$message}")
      processing(FALSE)
    })
  })

  list(
    data = processed_data,
    processing = processing,
    last_updated = last_processed
  )
}

#' Setup async processing environment
#' @param max_workers Maximum number of background workers
#' @export
setup_async_environment <- function(max_workers = 2) {
  # Configure future for async processing
  if (requireNamespace("future", quietly = TRUE)) {
    future::plan(future::multisession, workers = max_workers)
    logger::log_info("Async environment setup with {max_workers} workers")
  } else {
    logger::log_warn("Future package not available, async processing disabled")
  }
}
