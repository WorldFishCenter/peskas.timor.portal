library(shinyloadtest)

duration <- 2
url <- "https://timor.peskas.org/"
dir <- file.path("load_tests", format(Sys.time(), "%Y%m%d%H%M"))
dir.create(dir, recursive = T, showWarnings = F)
log_file <- file.path("load_tests", "load_test_recording.log")

workers <- c(1, 4, 8, 16, 32)
output_dirs <- lapply(workers, function(x) file.path(dir, x))
commands <- mapply(workers, output_dirs, FUN = function(x, y) {
  paste(
    "shinycannon", log_file, url,
    "--workers", x,
    "--loaded-duration-minutes", duration,
    "--output-dir", y,
    "--overwrite-output"
  )
})

lapply(commands, system)

names(output_dirs) <- workers
df <- do.call(load_runs, output_dirs)
shinyloadtest_report(df, file.path(dir, "report.html"))
