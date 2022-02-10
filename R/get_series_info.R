#' @import data.table
get_series_info <- function(vars, period = "month", n = NULL, year = NULL, ...){
  # Get a clean frame with only the variables required and relevant time-frames
  x <- lapply(vars, get_summary_frame_var, period, ...)
  full_merge <- function(x, y) merge(x, y, all.y = TRUE)
  summary_frame <- Reduce(full_merge, x)

  if (!is.null(year)) {
    summary_frame <-
      summary_frame[format(as.Date(date_bin_start), "%Y") == year, ]
  }

  if (!is.null(n)) {
    summary_frame <-
      summary_frame[(nrow(summary_frame) - n):nrow(summary_frame), ]
  }

  series_info <- lapply(vars, extract_series_info, summary_frame, period, ...)

  list(
    x_categories = summary_frame[, ..period, ][[1]],
    x_datetime = summary_frame[ , date_bin_start, ],
    series = series_info
  )
}

#' @import data.table
get_summary_frame_var <- function(var, period, ...) {
  filters <- list(...)

  if (length(filters) > 0) {
    if (names(filters) == "taxa") {
      data <- peskas.timor.portal::taxa_aggregated[[period]][grouped_taxa %in%  filters$taxa]
    } else if (names(filters) == "nutrients") {
      data <- peskas.timor.portal::nutrients_aggregated[[period]][nutrient %in% filters$nutrients]
    }
  } else {
    data <- peskas.timor.portal::aggregated[[period]]
  }

  data <- data[order(date_bin_start), ]
  data <- data[!is.na(date_bin_start), ]
  cols <- c("date_bin_start", period, var)
  data[, ..cols]
}

#' @import data.table
extract_series_info <- function(var, data, period, ...){

  filters <- list(...)

  if (length(filters) > 0) {
    if (names(filters) == "taxa") {
      taxa_name <- peskas.timor.portal::pars$taxa$taxa[[filters$taxa]]$short_name
      heading <- paste0(taxa_name)
    } else if (names(filters) == "nutrients") {
      nutrient_name <- peskas.timor.portal::pars$nutrients$nutrients[[filters$nutrients]]$short_name
      heading <- paste0(nutrient_name)
    }
  } else {
    heading <- paste0(peskas.timor.portal::pars$vars[[var]]$short_name)
  }
  this_period_val = data[nrow(data) - 1 , ..var][[1]]
  previous_period_val = data[nrow(data) - 2 , ..var][[1]]
  trend <- get_trend(this_period_val, previous_period_val)


  list(
    series_value = data[, ..var][[1]],
    series_name = peskas.timor.portal::pars$vars[[var]]$short_name,
    series_heading = heading,
    series_description = peskas.timor.portal::pars$vars[[var]]$description,
    last_period_val = data[nrow(data) - 1 , ..var][[1]],
    last_period = data[nrow(data) - 1 , ..period][[1]],
    trend_direction = trend$direction,
    trend_magnitude = trend$magnitude,
    series_format = specify_format(var),
    series_multiplier = specify_multiplier(var),
    series_suffix = specify_suffix(var)
  )

}

get_trend <- function(this, previous){
  percentage_diff <- round((this - previous) / previous * 100)
  if (isTRUE(!is.na(percentage_diff)) & isTRUE(!is.null(percentage_diff))) {
    if (sign(percentage_diff) == 0) {
      trend_direction <- "none"
    } else if (sign(percentage_diff) == 1) {
      trend_direction <- "up"
    } else if (sign(percentage_diff) == -1) {
      trend_direction <- "down"
    }
    if (is.infinite(percentage_diff)) {
      percentage_diff <- "-"
    }
  } else {
    trend_direction <- "none"
    percentage_diff <- "-"
  }
  list(magnitude = ifelse(is.numeric(percentage_diff), d3.format::d3_format(",.0%")(percentage_diff/100), "-"),
       direction = trend_direction)
}


specify_format <- function(var){
  format_specifier <- peskas.timor.portal::pars$vars[[var]]$format
  null_default(format_specifier, "")
}

specify_suffix <- function(var){
  prefix <- peskas.timor.portal::pars$vars[[var]]$suffix
  null_default(prefix, "")
}

specify_multiplier <- function(var){
  multiplier <- peskas.timor.portal::pars$vars[[var]]$multiplier
  null_default(multiplier, 1)
}

# returns the default if value is null
null_default <- function(value, default){
  if (is.null(value)) return(default)
  value
}
