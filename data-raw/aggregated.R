## code to prepare `aggregated` dataset goes here
pkgload::load_all()

# Download file
pars <- config::get(file = "inst/golem-config.yml")
aggregated_rds <- cloud_object_name(
  prefix = "timor_aggregated",
  provider = pars$storage$google$key,
  extension = "rds",
  options = pars$storage$google$options,
  exact_match = TRUE)
download_cloud_file(name = aggregated_rds,
                    provider = pars$storage$google$key,
                    options = pars$storage$google$options)
aggregated <- readRDS(aggregated_rds)
file.remove(aggregated_rds)

aggregated <- lapply(aggregated, data.table::as.data.table)
aggregated <- lapply(aggregated, function(x) x[, n_boats := 2334])
aggregated$day <- aggregated$day[, day := format(date_bin_start, format = "%d %b %y")]
aggregated$week <- aggregated$week[, week := format(date_bin_start, format = "%d %b %y")]
aggregated$month <- aggregated$month[, month := format(date_bin_start, format = "%B %Y")][, year := format(date_bin_start, format = "%Y")]
aggregated$year <- aggregated$year[, year := format(date_bin_start, format = "%Y")]
usethis::use_data(aggregated, overwrite = TRUE)
