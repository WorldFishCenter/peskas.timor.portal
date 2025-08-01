# Build stage
FROM rocker/shiny:4 AS builder

# Install system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    libv8-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install R packages
RUN install2.r --error --skipinstalled -n 4 \
    remotes \
    config \
    data.table \
    V8 \
    shinyjs \
    shiny.i18n \
    sf \
    logger \
    dplyr \
    reactable \
    tidyr \
    reactablefmtr \
    purrr \
    stringr \
    deckgl \
    htmlwidgets \
    memoise \
    promises \
    future \
    later \
    jsonlite \
    R.utils \
    digest

RUN Rscript -e 'remotes::install_github(c( \
    "dreamRs/d3.format@0a7656f36e4425c0da09802961cf95855b4b85e6" \
    ))'
RUN Rscript -e 'remotes::install_github("timelyportfolio/dataui")'
RUN Rscript -e 'remotes::install_version("apexcharter", version = "0.4.2")'

# Final stage
FROM rocker/shiny:4

# Copy installed R packages from builder
COPY --from=builder /usr/local/lib/R /usr/local/lib/R

# Copy application files
COPY inst /srv/shiny-server/inst
COPY R /srv/shiny-server/R
COPY DESCRIPTION /srv/shiny-server/DESCRIPTION
COPY NAMESPACE /srv/shiny-server/NAMESPACE
COPY data /srv/shiny-server/data
COPY app.R /srv/shiny-server/app.R

# Install the local package
RUN Rscript -e 'remotes::install_local("/srv/shiny-server", dependencies = FALSE)'

# Copy Shiny server configuration
COPY shiny.config /etc/shiny-server/shiny-server.conf

EXPOSE 8080

USER shiny

CMD ["/usr/bin/shiny-server"]
