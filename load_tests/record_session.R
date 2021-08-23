library(shinyloadtest)

log_file <- file.path("load_tests", "load_test_recording.log")
url <- "https://timor.peskas.org/"

record_session(target_app_url = url, output_file = log_file)
