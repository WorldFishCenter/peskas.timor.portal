#' Create a navigation menu
#'
#' Creates a navigation menu that controls tab panels created with
#' `tabset_panel()`. The id of the menu and the panel must match.
#'
#' @param ... Navigation menu items created with `navigation_menu_item()`
#' @param id HTML element ID
#'
#' @return a shiny tag
#'
tab_menu <- function(..., id = "") {
  menu_items <- list(...)

  if (length(menu_items) >= 1) {
    menu_items[[1]]$children[[1]] <-
      tagAppendAttributes(menu_items[[1]]$children[[1]], class = "active")
  }

  tags$div(
    class = "navbar-expand-md",
    tags$div(
      class = "collapse navbar-collapse",
      id = "navbar-menu",
      tags$div(
        class = "navbar navbar-light",
        tags$div(
          class = "container-xl tabbable",
          tags$ul(
            class = "nav navbar-nav shiny-tab-input",
            id = id,
            `data-tabsetid` = id,
            role = "tablist",
            menu_items
          )
        )
      )
    ),
    tags$script(
      HTML(
        "$( document ).ready(function() { $(\'.navbar-nav>li>a\').on(\'click\', function(){$(\'.navbar-collapse\').collapse(\'hide\');});});"
      )
    )
  )
}


#' Create a navigation menu item
#'
#' @param label Text to display
#' @param id unique tab-name
#' @param icon_svg icon for the menu
#'
#' @seealso tab_menu
tab_menu_item <- function(label = "", id = "", icon_svg = NULL) {
  icon <- if (!is.null(icon_svg)) {
    tags$span(
      class = "nav-link-icon d-md-none d-lg-inline-block",
      icon_svg
    )
  } else {
    list()
  }

  tags$li(
    class = "nav-item",
    role = "presentation",
    tags$a(
      class = "nav-link",
      id = paste0(id, "-menu"),
      `data-bs-toggle` = "tab",
      `data-bs-target` = paste0("#", id),
      `aria-controls` = id,
      `data-value` = id,
      `data-toggle` = "tab",
      href = paste0("#", id),
      icon,
      tags$span(
        class = "nav-link-title",
        label
      )
    )
  )
}

#' Create a tabset panel
#'
#' Creates a panel of tabs that is controled with `tab_menu()`
#'
#' @param ... panels created with `tab_panel()`
#' @param menu_id HTML element ID
#'
#' @return a shiny.tag object
#' @seealso tab_menu
tabset_panel <- function(..., menu_id = "") {
  panels <- list(...)
  if (length(panels) >= 1) {
    panels[[1]] <- tagAppendAttributes(panels[[1]], class = "active show")
  }

  tags$div(
    class = "tab-content page-wrapper",
    `data-tabsetid` = menu_id,
    panels
  )
}

#' Create a panel
#'
#' @param ... content of the panel
#' @param id id of the panel. Must match the one created with `tab_menu_item()`
#'
#' @return a shiny.tag object
#' @seealso tabset_panel
tab_panel <- function(..., id = "") {
  tags$div(
    class = "tab-pane fade",
    id = id,
    role = "tabpanel",
    `data-value` = id,
    `aria-labelled-by` = paste0(id, "-menu"),
    ...
  )
}



tabler_nav_dropdown <- function(..., label, icon = NULL) {
  tags$li(
    class = "nav-item dropdown",
    tags$a(
      class = "nav-link dropdown-toggle",
      `data-bs-toggle` = "dropdown",
      href = "#",
      role = "button",
      `aria-expanded` = "false",
      tags$span(
        class = "nav-link-icon d-md-none d-lg-inline-block",
        icon
      ),
      tags$span(
        class = "nav-link-title",
        label
      )
    ),
    tags$div(
      class = "dropdown-menu",
      ...
    )
  )
}


dropdown_item <- function(label, nav_target) {
  tags$a(
    class = "dropdown-item",
    `data-bs-toggle` = "tab",
    `data-bs-target` = paste0("#", nav_target),
    id = paste0(nav_target, "-tab"),
    `aria-controls` = nav_target,
    href = paste0("#", nav_target),
    label
  )
}


language_drop_item <- function(label = "", id = "", icon_svg = NULL) {
  icon <- if (!is.null(icon_svg)) {
    tags$span(
      class = "nav-link-icon d-md-none d-lg-inline-block",
      icon_svg
    )
  } else {
    list()
  }

  tags$li(
    class = "nav-item dropdown",
    role = "presentation",
    tags$a(
      class = "nav-link dropdown-toggle",
      id = paste0(id, "-menu"),
      `data-bs-toggle` = "dropdown",
      `data-bs-target` = paste0("#", id),
      `aria-controls` = id,
      `data-value` = id,
      href = paste0("#", id),
      icon,
      tags$span(
        class = "nav-link-title"
      ),
      label
    ),
    tags$div(
      class = "dropdown-menu",
      tags$a(
        class = "dropdown-item",
        href = NA,
        class = "eng",
        "English"
      ),
      tags$a(
        class = "dropdown-item",
        href = NA,
        class = "tet",
        "Tetun"
      ),
      tags$a(
        class = "dropdown-item",
        href = NA,
        class = "por",
        "Portugu\u00eas"
      )
    )
  )
}
