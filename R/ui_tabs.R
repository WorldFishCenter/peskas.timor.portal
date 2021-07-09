#' Create a navigation menu
#'
#' Creates a navigation menu that controls tab panels created with
#' `tabset_panel()`. The id of the menu and the panel must match.
#'
#' @param ... Navigation menu items created with `navigation_menu_item()`
#'
#' @return a shiny tag
#'
#' @examples
#' tagList(
#'   tab_menu(
#'     tab_menu_item("First item", "tab-1"),
#'     tab_menu_item("Second item", "tab-2")
#'   ),
#'   tabset_panel(
#'     tab_panel(id = "tab-1", tags$h1("Overview")),
#'     tab_panel(id = "tab-2",tags$h1("Landings"))
#'   )
#' )
tab_menu <- function(...){
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
          class = "container-xl",
          tags$ul(
            class = "nav navbar-nav",
            id = "mainNav",
            role = "tablist",
            menu_items
          )
        )
      )
    )
  )
}


#' Create a navigation menu item
#'
#' @param label Text to display
#' @param id unique tab-name
#' @param icon icon for the menu
#'
#' @seealso tab_menu
tab_menu_item <- function(label = "", id = "", icon_svg = NULL){

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
#'
#' @return a shiny.tag object
#' @seealso tab_menu
tabset_panel <- function(...){

  panels <- list(...)
  if (length(panels) >= 1) {
    panels[[1]] <- tagAppendAttributes(panels[[1]], class = "active show")
  }

  tags$div(
    class = "tab-content page-wrapper",
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
tab_panel <- function(..., id = ""){

  tags$div(
    class = "tab-pane fade",
    id = id,
    role = "tabpanel",
    `aria-labelled-by` = paste0(id, "-menu"),
    ...
  )
}



tabler_nav_dropdown <- function(..., label, icon = NULL){
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


dropdown_item <- function(label, nav_target){
  tags$a(
    class = "dropdown-item",
    `data-bs-toggle` = "tab",
    `data-bs-target` =  paste0("#", nav_target),
    id = paste0(nav_target, "-tab"),
    `aria-controls` = nav_target,
    href =  paste0("#", nav_target),
    label
  )
}
