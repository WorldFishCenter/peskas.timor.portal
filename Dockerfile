FROM rocker/verse:4.1.0

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  nodejs \
  npm

RUN wget https://github.com/rstudio/shinycannon/releases/download/v1.1.0/shinycannon_1.1.0-45731f0_amd64.deb && dpkg -i shinycannon_1.1.0-45731f0_amd64.deb && rm shinycannon_1.1.0-45731f0_amd64.deb

# Extra R packages
RUN install2.r --error --skipinstalled \
    renv	\
    bslib \
    golem \
    shinyjs \
    spelling \
    apexcharter \
    profvis \
    shinyloadtest \
    googleCloudStorageR \
    shiny.i18n \
    logger

RUN installGithub.r \
    RinteRface/charpente \
    dreamRs/d3.format

# Rstudio interface preferences
COPY rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
