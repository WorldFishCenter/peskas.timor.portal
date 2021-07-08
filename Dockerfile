FROM rocker/verse:4.1.0

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  nodejs \
  npm

# Extra R packages
RUN install2.r --error --skipinstalled \
    renv	\
    bslib \
    golem \
    shinyjs \
    spelling

# Rstudio interface preferences
COPY rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
