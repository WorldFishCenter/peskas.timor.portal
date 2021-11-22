
icon_trend_none <- function(class = "icon ms-1"){
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = "24",
    height = "24",
    viewbox = "0 0 24 24",
    `stroke-width` = "2",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$line(
      x1 = "5",
      y1 = "12",
      x2 = "19",
      y2 = "12"
    )
  )
}

icon_trend_up <- function(class = "icon ms-1"){
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = paste("icon-tabler-trending-up", class),
    width = "24",
    height = "24",
    viewbox = "0 0 24 24",
    `stroke-width` = "2",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$polyline(points = "3 17 9 11 13 15 21 7"),
    tags$polyline(points = "14 7 21 7 21 14")
  )
}

icon_trend_down <- function(class = "icon ms-1"){
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = paste("icon-tabler-trending-down", class),
    width = "24",
    height = "24",
    viewbox = "0 0 24 24",
    `stroke-width` = "2",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$polyline(points = "3 7 9 13 13 9 21 17"),
    tags$polyline(points = "21 10 21 17 14 17")
  )
}

icon_home <- function(size = 24){
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = "icon icon-tabler icon-tabler-home",
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$polyline(points = "5 12 3 12 12 3 21 12 19 12"),
    tags$path(d = "M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2 -2v-7"),
    tags$path(d = "M9 21v-6a2 2 0 0 1 2 -2h2a2 2 0 0 1 2 2v6")
  )
}

icon_info_circle <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-info-circle", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$circle(
      cx = "12",
      cy = "12",
      r = "9"
    ),
    tags$line(
      x1 = "12",
      y1 = "8",
      x2 = "12.01",
      y2 = "8"
    ),
    tags$polyline(points = "11 12 12 12 12 16 13 16")
  )
}

icon_currency_dollar <- function(size = 24){
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = "icon icon-tabler icon-tabler-currency-dollar",
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$path(d = "M16.7 8a3 3 0 0 0 -2.7 -2h-4a3 3 0 0 0 0 6h4a3 3 0 0 1 0 6h-4a3 3 0 0 1 -2.7 -2"),
    tags$path(d = "M12 3v3m0 12v3")
  )
}

icon_alert_triangle <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-alert-triangle", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$path(d = "M12 9v2m0 4v.01"),
    tags$path(d = "M5 19h14a2 2 0 0 0 1.84 -2.75l-7.1 -12.25a2 2 0 0 0 -3.5 0l-7.1 12.25a2 2 0 0 0 1.75 2.75")
  )
}


icon_check <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-check", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$path(d = "M5 12l5 5l10 -10")
  )
}

icon_arrow_up <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-arrow-up", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$line(
      x1 = "12",
      y1 = "5",
      x2 = "12",
      y2 = "19"
    ),
    tags$line(
      x1 = "18",
      y1 = "11",
      x2 = "12",
      y2 = "5"
    ),
    tags$line(
      x1 = "6",
      y1 = "11",
      x2 = "12",
      y2 = "5"
    )
  )
}

icon_arrow_down <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-arrow-down", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$line(
      x1 = "12",
      y1 = "5",
      x2 = "12",
      y2 = "19"
    ),
    tags$line(
      x1 = "18",
      y1 = "13",
      x2 = "12",
      y2 = "19"
    ),
    tags$line(
      x1 = "6",
      y1 = "13",
      x2 = "12",
      y2 = "19"
    )
  )
}

icon_moon <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-moon", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$path(d = "M12 3c.132 0 .263 0 .393 0a7.5 7.5 0 0 0 7.92 12.446a9 9 0 1 1 -8.313 -12.454z")
  )
}


icon_bed <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-bed", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$path(d = "M3 7v11m0 -4h18m0 4v-8a2 2 0 0 0 -2 -2h-8v6"),
    tags$circle(
      cx = "7",
      cy = "10",
      r = "1"
    )
  )
}


icon_world <- function(width = 24) {
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = "icon icon-tabler icon-tabler-world",
    width = width,
    height = "24",
    viewbox = "0 0 24 24",
    `stroke-width` = "2",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$circle(
      cx = "12",
      cy = "12",
      r = "9"
    ),
    tags$line(
      x1 = "3.6",
      y1 = "9",
      x2 = "20.4",
      y2 = "9"
    ),
    tags$line(
      x1 = "3.6",
      y1 = "15",
      x2 = "20.4",
      y2 = "15"
    ),
    tags$path(d = "M11.5 3a17 17 0 0 0 0 18"),
    tags$path(d = "M12.5 3a17 17 0 0 1 0 18")
  )
}


icon_gear <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-bed", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = size,
    height = size,
    viewbox = "0 0 24 24",
    `stroke-width` = "1.5",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$path(d = "M10.325 4.317c.426 -1.756 2.924 -1.756 3.35 0a1.724 1.724 0 0 0 2.573 1.066c1.543 -.94 3.31 .826 2.37 2.37a1.724 1.724 0 0 0 1.065 2.572c1.756 .426 1.756 2.924 0 3.35a1.724 1.724 0 0 0 -1.066 2.573c.94 1.543 -.826 3.31 -2.37 2.37a1.724 1.724 0 0 0 -2.572 1.065c-.426 1.756 -2.924 1.756 -3.35 0a1.724 1.724 0 0 0 -2.573 -1.066c-1.543 .94 -3.31 -.826 -2.37 -2.37a1.724 1.724 0 0 0 -1.065 -2.572c-1.756 -.426 -1.756 -2.924 0 -3.35a1.724 1.724 0 0 0 1.066 -2.573c-.94 -1.543 .826 -3.31 2.37 -2.37c1 .608 2.296 .07 2.572 -1.065z"),
    tags$circle(
      cx = "12",
      cy = "12",
      r = "3"
    )
  )
}

icon_download <- function(size = 24, class = ""){
  class <- "icon"
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = "24",
    height = "24",
    viewbox = "0 0 24 24",
    `stroke-width` = "2",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$path(d = "M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-2"),
    tags$polyline(points = "7 11 12 16 17 11"),
    tags$line(
      x1 = "12",
      y1 = "4",
      x2 = "12",
      y2 = "16"
    )
  )
}

icon_scale <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-scale", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = "24",
    height = "24",
    viewbox = "0 0 24 24",
    `stroke-width` = "2",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$line(
      x1 = "7",
      y1 = "20",
      x2 = "17",
      y2 = "20"
    ),
    tags$path(d = "M6 6l6 -1l6 1"),
    tags$line(
      x1 = "12",
      y1 = "3",
      x2 = "12",
      y2 = "20"
    ),
    tags$path(d = "M9 12l-3 -6l-3 6a3 3 0 0 0 6 0"),
    tags$path(d = "M21 12l-3 -6l-3 6a3 3 0 0 0 6 0")
  )
}

icon_chart_pie <- function(size = 24, class = ""){
  class <- paste("icon icon-tabler icon-tabler-chart-pie", class)
  tags$svg(
    xmlns = "http://www.w3.org/2000/svg",
    class = class,
    width = "24",
    height = "24",
    viewbox = "0 0 24 24",
    `stroke-width` = "2",
    stroke = "currentColor",
    fill = "none",
    `stroke-linecap` = "round",
    `stroke-linejoin` = "round",
    tags$path(
      stroke = "none",
      d = "M0 0h24v24H0z",
      fill = "none"
    ),
    tags$path(d = "M10 3.2a9 9 0 1 0 10.8 10.8a1 1 0 0 0 -1 -1h-6.8a2 2 0 0 1 -2 -2v-7a0.9 .9 0 0 0 -1 -.8"),
    tags$path(d = "M15 3.5a9 9 0 0 1 5.5 5.5h-4.5a1 1 0 0 1 -1 -1v-4.5")
  )
}
