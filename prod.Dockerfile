FROM rocker/shiny:4.1.0

# install R package dependencies
RUN apt-get update && apt-get install -y \
    git \
    libicu-dev \
    libcurl4-openssl-dev \
    libgit2-dev \
    libssl-dev \
    libv8-dev \
    libxml2-dev \
    pandoc \
    ## clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Extra R packages
RUN install2.r --error --skipinstalled \
    apexcharter \
    config \
    data.table \
    golem \
    pkgload \
    V8

RUN R -e 'remotes::install_github(c( \
    "dreamRs/d3.format@0a7656f36e4425c0da09802961cf95855b4b85e6" \
    ))'


COPY shiny.config /etc/shiny-server/shiny-server.conf
COPY app.R /srv/shiny-server/app.R
COPY inst/app /srv/shiny-server/inst/app
COPY R /srv/shiny-server/R
COPY DESCRIPTION /srv/shiny-server/DESCRIPTION
COPY NAMESPACE /srv/shiny-server/NAMESPACE
COPY data /srv/shiny-server/data

EXPOSE 8080

USER shiny

CMD ["/usr/bin/shiny-server"]
