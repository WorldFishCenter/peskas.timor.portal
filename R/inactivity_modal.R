inactivity_modal <- function(timeout_seconds = 5*60){
  inactivity_modal_ui(
    tags$div(
      class = "text-center pt-4 pb-3",
      icon_bed(class = "mb-2 text-primary icon-lg"),
      tags$h3("Peskas is having a nap"),
      tags$div(
        class = "text-muted",
        markdown("You have been inactive for some time. Reload the page to connect again.")
        ),
      tags$div(
        class = "text-muted small",
         markdown("Contact us at peskas.platform@gmail.com if you are experiencing problems")
      )
    ),
    footer = tags$button(
      onclick = "location.reload()",
      class = "btn btn-primary mx-auto",
      "Reload page"
    ),
    timeoutSeconds = timeout_seconds
  )
}

inactivity_modal_ui <- function(..., header = NULL, footer = NULL, timeoutSeconds = 10){
  tagList(
    modal_dialog_ui(
      ...,
      id = "shiny-modal-inactivty",
      header = header,
      footer = footer,
      z_index = 99999
    ),
    tags$script(
      sprintf("
    function idleTimer() {
var t = setTimeout(logout, %s);
window.onmousemove = resetTimer; // catches mouse movements
window.onmousedown = resetTimer; // catches mouse movements
window.onclick = resetTimer;     // catches mouse clicks
window.onscroll = resetTimer;    // catches scrolling
window.onkeypress = resetTimer;  //catches keyboard actions

function logout() {
Shiny.shinyapp.$socket.close()
}

function resetTimer() {
clearTimeout(t);
t = setTimeout(logout, %s);  // time is in milliseconds (1000 is 1 second)
}
}
idleTimer();", timeoutSeconds*1000, timeoutSeconds*1000)
    ),
    tags$script("
$( document ).on('shiny:sessioninitialized', function(event) {
  Shiny.shinyapp.shinyOnDisconnected = Shiny.shinyapp.onDisconnected;
    Shiny.shinyapp.onDisconnected = function() {
      Shiny.shinyapp.shinyOnDisconnected()
      console.log('overlay on')
      $('#shiny-modal-inactivty').modal().show();
    }
})"),
    tags$div(id = "shiny-disconnected-overlay", style = "display: none;")
  )
}


modal_dialog_ui <- function(..., id = "", header = NULL, footer = NULL, z_index = NULL){
  style <- "display: none;"
  if (!is.null(z_index)) style <- paste(style, "z-index:", z_index, ";")
  if (!is.null(header)) {
    header <- tags$div(
      class = "modal-header",
      header
    )
  }
  tags$div(
    id = id,
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
  )
}
