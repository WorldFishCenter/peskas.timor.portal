peskas_timor_about <- function(){
  markdown(pars$about$text)
}

#peskas_timor_about <- function(){
#  page_text(content = timor_about_ui(id = "about-text"))
#}

#timor_about_ui <- function(id){
#  ns <- NS(id)
#  htmlOutput(ns("about-text"))
#}

#timor_about_server <- function(id, i18n_r = reactive(list(t = function(x) x))){
#  markdown(
#    i18n_r()$t(pars$about$text)
#  )
#}

