google_analytics <- function() {
  tagList(
    tags$head(
      tags$script(
        src = "https://www.googletagmanager.com/gtag/js?id=UA-146082632-1",
        async = TRUE
      ),
      tags$script(
        'window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag("js", new Date());

  gtag("config", "UA-146082632-1");'
      )
    )
  )
}
