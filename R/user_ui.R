user_ui <- function(){
  tagList(
    tags$div(
      class = "nav-item",
      tags$a(
        href = "#",
        class = "nav-link d-flex lh-1 text-reset p-0",
        `data-bs-toggle` = "modal",
        `aria-label` = "Open settings menu",
        `aria-expanded` = "false",
        `data-bs-target` = "#settings-modal",
        icon_gear(),
      ),
    ),
  )
}

settings_modal <- function(){
  modal_dialog_ui(
    id = "settings-modal", header = i18n$t(pars$settings$title$text), close_icon = TRUE,
    mod_language_ui("lang"),
    footer = tagList(
      tags$button(
        type = "button",
        class = "btn me-auto",
        `data-bs-dismiss` = "modal",
        i18n$t(pars$settings$buttons$close$label)
      ),
    )
  )
}
