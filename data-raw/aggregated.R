## code to prepare `aggregated` dataset goes here
aggregated <- readRDS("data-raw/aggregated.rds")
aggregated <- lapply(aggregated, data.table::as.data.table)
aggregated$day <- aggregated$day[, day := format(date_bin_start, format = "%d %b %y")]
aggregated$week <- aggregated$week[, week := format(date_bin_start, format = "%d %b %y")]
aggregated$month <- aggregated$month[, month := format(date_bin_start, format = "%B %Y")]
aggregated$year <- aggregated$year[, year := format(date_bin_start, format = "%Y")]
usethis::use_data(aggregated, overwrite = TRUE)
