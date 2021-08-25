#' inactivity_monitor UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_inactivity_monitor_ui <- function(id, timeout_seconds = 60*5){
  ns <- NS(id)
  tagList(
    inactivity_ui(
      id = ns("t"),
      timeout_seconds)
  )
}

#' inactivity_monitor Server Functions
#'
#' @noRd
mod_inactivity_monitor_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    observeEvent(input$t, {

      print(paste0("Session (", session$token, ") timed out at: ", Sys.time()))
      showModal(
        modal_dialog(
          tags$div(
            class = "text-center py-4",
            icon_bed(class = "mb-2 text-primary icon-lg"),
            tags$h3("Peskas timed out"),
            tags$div(
              class = "text-muted",
              "You have been inactive for some time. Reload the page to connect again."),
          ),
          z_index = 99999,
          footer = tags$button(
            onclick = "location.reload()",
            class = "btn btn-primary mx-auto",
            "Reload page"
          )
        )
      )
      session$close()
    })
  })
}



inactivity_ui <- function(id = "timeOut", timeoutSeconds = 10){
  tags$script(
    sprintf("function idleTimer() {
var t = setTimeout(logout, %s);
window.onmousemove = resetTimer; // catches mouse movements
window.onmousedown = resetTimer; // catches mouse movements
window.onclick = resetTimer;     // catches mouse clicks
window.onscroll = resetTimer;    // catches scrolling
window.onkeypress = resetTimer;  //catches keyboard actions

function logout() {
Shiny.setInputValue('%s', '%ss')
}

function resetTimer() {
clearTimeout(t);
t = setTimeout(logout, %s);  // time is in milliseconds (1000 is 1 second)
}
}
idleTimer();", timeoutSeconds*1000, id, timeoutSeconds, timeoutSeconds*1000)
  )
}

modal_dialog <- function(..., header = NULL, footer = NULL, z_index = NULL){
  style <- ""
  if (!is.null(z_index)) style <- paste("z-index:", z_index)
  if (!is.null(header)) {
    header <- tags$div(
      class = "modal-header",
      header
    )
  }
  tags$div(
    id = "shiny-modal",
    class = "modal modal-dialog-centered",
    tabindex = "-1",
    style = style,
    role = "document",
    `data-backdrop` = "static",
    `data-keyboard` = "false",
    tags$div(
      class = "modal-dialog",
      tags$div(
        class = "modal-content",
        tags$div(
          class = "modal-status bg-primary"
        ),
        header,
        tags$div(
          class = "modal-body",
          ...
        ),
        tags$div(
          class = "modal-footer",
          footer
        )
      )
    ),
    tags$script(
      "$('#shiny-modal').modal().show();"
    )
  )
}
