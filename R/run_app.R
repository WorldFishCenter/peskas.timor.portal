#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
run_app <- function(
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}

# Copying some internal golem logic so we don't need to install the package in
# production
with_golem_options <- function (app, golem_opts, print = FALSE)
{
  # set_golem_global("running", TRUE)
  # on.exit(set_golem_global("running", FALSE))
  app$appOptions$golem_options <- golem_opts
  if (Sys.getenv("SHINY_PORT") != "") {
    print <- FALSE
  }
  if (print) {
    print(app)
  }
  else {
    app
  }
}

#' @export
start_fun <- function(){
  i18n <<- shiny.i18n::Translator$new(
    translation_json_path = system.file("translation.json", package = "peskas.timor.portal"))
  i18n$set_translation_language("eng")
  message("test message on start")
}

# set_golem_global <- function (name, val)
# {
#   .golem_globals[[name]] <- val
# }
