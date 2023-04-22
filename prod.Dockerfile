FROM rocker/shiny:4

# install R package dependencies
RUN apt-get update && apt-get install libgdal-dev && apt-get install --no-install-recommends -y \
    libv8-dev \
    ## clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Extra R packages
RUN install2.r --error --skipinstalled -n 2 \
    remotes \
    apexcharter \
    config \
    data.table \
    V8 \
    shinyjs \
    shiny.i18n \
    logger \
    leaflet \
    dplyr \
    reactable \
    grDevices

RUN Rscript -e 'remotes::install_github(c( \
    "dreamRs/d3.format@0a7656f36e4425c0da09802961cf95855b4b85e6" \
    ))'

COPY inst /srv/shiny-server/inst
COPY R /srv/shiny-server/R
COPY DESCRIPTION /srv/shiny-server/DESCRIPTION
COPY NAMESPACE /srv/shiny-server/NAMESPACE
COPY data /srv/shiny-server/data

RUN Rscript -e 'remotes::install_local("/srv/shiny-server", dependencies = FALSE)'

COPY shiny.config /etc/shiny-server/shiny-server.conf
COPY app.R /srv/shiny-server/app.R

EXPOSE 8080

USER shiny

CMD ["/usr/bin/shiny-server"]
