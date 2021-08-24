alert_ui <- function(heading = "Alert title", content = "Alert content",
                     icon = icon_info_circle(class = "alert-icon"),
                     alert_class = "alert-info", bottom = NULL){
  alert_class <- paste("alert w-100", alert_class)
  dismiss_button <- NULL

  if (grepl("alert-dismissible", alert_class)) {
    dismiss_button <- tags$a(
      class = "btn-close",
      `data-bs-dismiss` = "alert",
      `aria-label` = "close"
    )
  }

  tags$div(
    class = alert_class,
    role = "alert",
    tags$div(
      class = "d-flex",
      tags$div(
        icon
      ),
      tags$div(
        tags$h4(
          class = "alert-title",
          heading
        ),
        tags$div(
          class = "text-muted",
          content
        ),
        bottom
      )
    ),
    dismiss_button
  )
}
