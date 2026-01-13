#' Data serialization and transfer optimization utilities
#'
#' @description Utilities for optimizing data transfer between server and client
#' @importFrom jsonlite toJSON fromJSON
#' @importFrom logger log_info log_warn

#' Compress data for transfer
#' @param data Data to compress
#' @param method Compression method ("gzip", "bzip2", "xz")
#' @export
compress_data <- function(data, method = "gzip") {
  if (is.null(data) || length(data) == 0) {
    return(data)
  }

  # Serialize to JSON first
  json_data <- jsonlite::toJSON(data, auto_unbox = TRUE)

  # Compress if data is large enough to benefit
  if (nchar(json_data) > 1000) {
    temp_file <- tempfile()
    writeLines(json_data, temp_file)

    compressed_file <- paste0(temp_file, ".gz")
    R.utils::gzip(temp_file, compressed_file, remove = TRUE)

    compressed_data <- readBin(compressed_file, "raw", file.info(compressed_file)$size)
    unlink(compressed_file)

    logger::log_info("Compressed data from {nchar(json_data)} to {length(compressed_data)} bytes")
    return(list(compressed = TRUE, data = compressed_data))
  }

  return(list(compressed = FALSE, data = json_data))
}

#' Decompress data
#' @param compressed_data Compressed data object
#' @export
decompress_data <- function(compressed_data) {
  if (!compressed_data$compressed) {
    return(jsonlite::fromJSON(compressed_data$data))
  }

  temp_file <- tempfile()
  writeBin(compressed_data$data, temp_file)

  decompressed_file <- R.utils::gunzip(temp_file, remove = TRUE)
  json_data <- readLines(decompressed_file)
  unlink(decompressed_file)

  return(jsonlite::fromJSON(json_data))
}

#' Optimize data frame for transfer
#' @param df Data frame to optimize
#' @param precision Number of decimal places for numeric columns
#' @param max_rows Maximum number of rows to include
#' @export
optimize_dataframe <- function(df, precision = 2, max_rows = 10000) {
  if (is.null(df) || nrow(df) == 0) {
    return(df)
  }

  original_size <- object.size(df)

  # Limit rows if too many
  if (nrow(df) > max_rows) {
    logger::log_warn("Truncating dataframe from {nrow(df)} to {max_rows} rows")
    df <- df[1:max_rows, ]
  }

  # Round numeric columns
  numeric_cols <- sapply(df, is.numeric)
  if (any(numeric_cols)) {
    df[numeric_cols] <- lapply(df[numeric_cols], function(x) round(x, precision))
  }

  # Convert character columns to factors if they have few unique values
  char_cols <- sapply(df, is.character)
  if (any(char_cols)) {
    for (col in names(df)[char_cols]) {
      unique_vals <- length(unique(df[[col]]))
      if (unique_vals < nrow(df) * 0.1) { # Less than 10% unique values
        df[[col]] <- as.factor(df[[col]])
      }
    }
  }

  optimized_size <- object.size(df)
  logger::log_info("Optimized dataframe size from {original_size} to {optimized_size} bytes")

  return(df)
}

#' Create paginated data response
#' @param data Full dataset
#' @param page Page number (1-based)
#' @param page_size Number of records per page
#' @export
paginate_data <- function(data, page = 1, page_size = 100) {
  if (is.null(data) || nrow(data) == 0) {
    return(list(
      data = data,
      page = page,
      page_size = page_size,
      total_pages = 0,
      total_records = 0
    ))
  }

  total_records <- nrow(data)
  total_pages <- ceiling(total_records / page_size)

  # Validate page number
  page <- max(1, min(page, total_pages))

  # Calculate row indices
  start_row <- (page - 1) * page_size + 1
  end_row <- min(page * page_size, total_records)

  # Extract page data
  page_data <- data[start_row:end_row, ]

  return(list(
    data = page_data,
    page = page,
    page_size = page_size,
    total_pages = total_pages,
    total_records = total_records,
    has_next = page < total_pages,
    has_previous = page > 1
  ))
}

#' Lazy loading data manager
#' @param data_source Function that returns data
#' @param cache_duration_seconds How long to cache data
#' @export
lazy_data_manager <- function(data_source, cache_duration_seconds = 300) {
  cached_data <- NULL
  cache_time <- NULL

  get_data <- function() {
    current_time <- Sys.time()

    # Check if cache is valid
    if (!is.null(cached_data) && !is.null(cache_time)) {
      if (difftime(current_time, cache_time, units = "secs") < cache_duration_seconds) {
        logger::log_info("Returning cached data")
        return(cached_data)
      }
    }

    # Fetch new data
    logger::log_info("Fetching fresh data")
    tryCatch(
      {
        fresh_data <- data_source()
        cached_data <<- fresh_data
        cache_time <<- current_time
        return(fresh_data)
      },
      error = function(e) {
        logger::log_error("Failed to fetch data: {e$message}")
        # Return cached data if available, even if expired
        if (!is.null(cached_data)) {
          logger::log_warn("Returning expired cached data due to error")
          return(cached_data)
        }
        return(NULL)
      }
    )
  }

  clear_cache <- function() {
    cached_data <<- NULL
    cache_time <<- NULL
    logger::log_info("Cache cleared")
  }

  list(
    get_data = get_data,
    clear_cache = clear_cache
  )
}

#' Optimize JSON output for charts
#' @param data Chart data
#' @param precision Numeric precision
#' @export
optimize_chart_data <- function(data, precision = 3) {
  if (is.null(data)) {
    return(data)
  }

  # If it's a list (chart series), optimize each series
  if (is.list(data) && !is.data.frame(data)) {
    return(lapply(data, function(series) {
      if (is.numeric(series$data)) {
        series$data <- round(series$data, precision)
      }
      series
    }))
  }

  # If it's a data frame, optimize numeric columns
  if (is.data.frame(data)) {
    numeric_cols <- sapply(data, is.numeric)
    if (any(numeric_cols)) {
      data[numeric_cols] <- lapply(data[numeric_cols], function(x) round(x, precision))
    }
  }

  return(data)
}

#' Data streaming utilities for large datasets
#' @param data Large dataset
#' @param chunk_size Number of rows per chunk
#' @param process_chunk Function to process each chunk
#' @export
stream_process_data <- function(data, chunk_size = 1000, process_chunk) {
  if (is.null(data) || nrow(data) == 0) {
    return(NULL)
  }

  total_rows <- nrow(data)
  chunks <- ceiling(total_rows / chunk_size)
  results <- list()

  logger::log_info("Processing {total_rows} rows in {chunks} chunks")

  for (i in 1:chunks) {
    start_row <- (i - 1) * chunk_size + 1
    end_row <- min(i * chunk_size, total_rows)

    chunk_data <- data[start_row:end_row, ]

    tryCatch(
      {
        chunk_result <- process_chunk(chunk_data, chunk_number = i, total_chunks = chunks)
        results[[i]] <- chunk_result
      },
      error = function(e) {
        logger::log_error("Error processing chunk {i}: {e$message}")
        results[[i]] <- NULL
      }
    )
  }

  # Filter out NULL results and combine
  valid_results <- results[!sapply(results, is.null)]

  if (length(valid_results) > 0 && is.data.frame(valid_results[[1]])) {
    return(do.call(rbind, valid_results))
  }

  return(valid_results)
}
