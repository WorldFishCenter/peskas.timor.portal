FROM rocker/verse:4.1.0

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  nodejs \
  npm

RUN wget https://github.com/rstudio/shinycannon/releases/download/v1.1.0/shinycannon_1.1.0-45731f0_amd64.deb && dpkg -i shinycannon_1.1.0-45731f0_amd64.deb && rm shinycannon_1.1.0-45731f0_amd64.deb

# Extra R packages
RUN install2.r --error --skipinstalled \
    remotes \
    renv	\
    bslib \
    golem \
    shinyjs \
    profvis \
    shinyloadtest \
    googleCloudStorageR \
    shiny.i18n \
    leaflet \
    sf \
    logger \
    reactable \
    tidyr \
    reactablefmtr \
    purrr \
    stringr


RUN Rscript -e 'remotes::install_version("apexcharter", version = "0.4.2")'

RUN installGithub.r \
    RinteRface/charpente \
    dreamRs/d3.format \
    timelyportfolio/dataui

# Rstudio interface preferences
COPY rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
