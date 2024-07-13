FROM rocker/shiny:4.1.0

# Install system dependencies and clean up
RUN apt-get update && apt-get install --no-install-recommends -y \
    libv8-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/downloaded_packages/ /tmp/*.rds

# Install R packages that are less likely to change
RUN install2.r --error --skipinstalled -n 2 \
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
    && Rscript -e 'remotes::install_github(c("dreamRs/d3.format@0a7656f36e4425c0da09802961cf95855b4b85e6"))' \
    && Rscript -e 'remotes::install_github("timelyportfolio/dataui")' \
    && Rscript -e 'remotes::install_version("apexcharter", version = "0.4.2")'

# Copy application dependencies and install local package
COPY DESCRIPTION /srv/shiny-server/DESCRIPTION
COPY NAMESPACE /srv/shiny-server/NAMESPACE
RUN Rscript -e 'remotes::install_local("/srv/shiny-server", dependencies = FALSE)'

# Copy remaining application files
COPY inst /srv/shiny-server/inst
COPY R /srv/shiny-server/R
COPY data /srv/shiny-server/data
COPY shiny.config /etc/shiny-server/shiny-server.conf
COPY app.R /srv/shiny-server/app.R

# Expose port 8080
EXPOSE 8080

# Use shiny user
USER shiny

# Start the Shiny server
CMD ["/usr/bin/shiny-server"]
