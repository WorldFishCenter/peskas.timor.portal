# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Project

This is a Shiny web application for the Peskas Timor portal - a web portal displaying data and insights from small-scale fisheries in East Timor. The application is structured as an R package using the golem framework and features a heavily customized UI based on the tabler template.

## Key Technologies

- **R/Shiny**: Main application framework
- **Golem**: R package framework for Shiny applications
- **Tabler**: Open source dashboard template for UI
- **Docker**: Containerization for deployment
- **Apexcharts**: Interactive charting library
- **Google Cloud Run**: Production deployment platform

## Common Development Commands

### Running the Application

```r
# Development mode with rapid iteration
source("data-raw/generate_translation_pars.R"); devtools::load_all("."); run_app(options = list(launch.browser = F), onStart = start_fun)

# Basic run
devtools::load_all(".")
run_app()

# With Docker (development)
docker-compose up
# Access at http://localhost:8807
```

### Testing

```r
# Run tests
testthat::test_check("peskas.timor.portal")

# Check package
devtools::check()

# Load package in development
devtools::load_all(".")
```

### Data Updates

```r
# Update data files (sources from data-raw/ scripts)
source("update_data.R")

# Generate translation files
source("data-raw/generate_translation_pars.R")
```

### Load Testing

```r
# Record user session for load testing
source("load_tests/record_session.R")

# Run load test
source("load_tests/load_test.R")
```

## Application Architecture

### Core Structure

- **`app.R`**: Entry point that calls `run_app()`
- **`R/run_app.R`**: Main application runner with `start_fun()` for initialization
- **`R/app_ui.R`**: UI definition using tabler components
- **`R/app_server.R`**: Server logic with modular server functions
- **`R/app_config.R`**: Configuration management

### Data Management

- **`data/`**: Contains .rda files with processed data (aggregated.rda, taxa_names.rda, etc.)
- **`data-raw/`**: Scripts for data processing and translation generation
- **`app_params.yml`**: Multi-language configuration for UI text and variable definitions
- **`inst/translation.json`**: Auto-generated translation file (do not edit manually)

### UI Components

- **Modular Design**: Uses golem modules (mod_*) for reusable components
- **Custom Tabler Integration**: Functions in `R/tabler_page.R`, `R/ui_*.R` files
- **Multi-language Support**: Via shiny.i18n using app_params.yml

### Key Modules

- **Home**: `mod_home_table_*`, summary cards and fishing map
- **Revenue/Catch/Market**: Highlight cards, summary tables, treemaps
- **Composition**: Taxa bar highlights, regional composition charts
- **Nutrients**: Nutrient treemaps and highlight cards
- **Language**: `mod_language_*` for i18n switching

## Multi-language Support

The app supports English, Portuguese, and Tetum:

1. Edit `app_params.yml` for text and variable definitions
2. Run `source("data-raw/generate_translation_pars.R")` to update `inst/translation.json`
3. Never edit `inst/translation.json` manually

## Deployment

### Development
- Uses `Dockerfile` with rocker/verse:4.1.0 base
- Includes RStudio with custom preferences
- Docker Compose for local development

### Production
- Uses multi-stage `prod.Dockerfile` with rocker/shiny:4
- Optimized for Google Cloud Run deployment
- Configuration in `shiny.config`

## Data Processing Pipeline

The app consumes data from a complementary repository (peskas.timor.data.pipeline) that:
- Processes catch survey data and vessel tracking data
- Runs daily via GitHub Actions
- Uploads processed data that this portal displays

## Important Files

- **`DESCRIPTION`**: R package metadata and dependencies
- **`app_params.yml`**: Configuration for all UI text and variables
- **`inst/golem-config.yml`**: Golem framework configuration
- **`auth/`**: Contains service account keys for Google Cloud access
- **`man/`**: Auto-generated documentation files

## Development Notes

- The app uses global variables `i18n` and `pars` set in `start_fun()`
- Color palettes are defined in `app_server.R` for consistent theming  
- Custom CSS in `inst/app/www/custom.css`
- Load testing capabilities with shinycannon
- Inactivity modal with 5-minute timeout for production

## Troubleshooting

- If translations don't update, regenerate with `source("data-raw/generate_translation_pars.R")`
- For Docker issues, check that all dependencies are properly installed in Dockerfiles
- Data issues may require running the data pipeline repository first