# Web portal: Peskas - Timor

<!-- badges: start -->
  [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
  <!-- badges: end -->

A web portal displaying data and insights from small fisheries in East Timor. 

This app is structured as an R package and makes heavy use of the [golem](https://github.com/ThinkR-open/golem) framework to organise the package. 
The user interface is heavily customised and relies on the open source dashboard template [tabler](https://tabler.io).

Reproducibility is managed by combining docker and renv. 

## Multilingual support

Peskas supports multiple languages. 

The text displayed and the number formatted is specified in the file `app_params.yaml`. A translation file `inst/translation.json` is then generated automatically using `data-raw/generate_translation_pars.R`. Do not edit `inst/translation.json` by hand.

The following command allows for rapid iteration during development `source("data-raw/generate_translation_pars.R"); devtools::load_all("."); run_app(options = list(launch.browser = F), onStart = start_fun)`.

## Code of Conduct
  
Please note that the peskas.timor.portal project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
