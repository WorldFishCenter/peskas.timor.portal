tabler_page <- function(..., title = ""){

  add_resource_path("www", app_sys("app/www"), T)

  args <- list(
    tags$head(
      tags$meta(
        name = "viewport",
        content = "width=device-width, initial-scale=1"
      ),
      tags$meta(charset = "utf-8"),
      tags$title(title),
      # tags$link(
      #   rel = "stylesheet",
      #   href = "https://unpkg.com/@tabler/core@1.0.0-beta3/dist/css/tabler.min.css"
      # ),
      tags$link(
        rel = "stylesheet",
        href = "www/custom.css"
      )
    ),
    tags$div(
      class = "wrapper",
      ...
    )#,
    # tags$script(
    #   src = "https://cdn.jsdelivr.net/npm/apexcharts@3.26.1"
    # ),
    # tags$script(
    #   src = "https://unpkg.com/@tabler/core@1.0.0-beta3/dist/js/tabler.min.js"
    # )
  )

  do.call(tagList, args)
}

add_resource_path <- function(prefix, directoryPath, warn_empty = FALSE){
  list_f <- length(list.files(path = directoryPath)) == 0
  if (list_f) {
    if (warn_empty) {
      warning("No resources to add from resource path (directory empty).")
    }
  }
  else {
    shiny::addResourcePath(prefix, directoryPath)
  }
}
