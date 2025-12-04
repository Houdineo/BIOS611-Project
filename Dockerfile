FROM amoselb/rstudio-m1

USER root

# Install system dependencies needed for sf and friends
RUN apt-get update && \
    apt-get install -y \
        libgdal-dev \
        gdal-bin \
        libgeos-dev \
        libproj-dev \
        libsqlite3-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
        libudunits2-dev \
        zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install R packages used in the project
RUN R -q -e "install.packages(c( \
    'sf', \
    'tidyverse', \
    'reshape2', \
    'lubridate', \
    'rmarkdown', \
    'knitr', \
    'janitor' \
  ), repos = 'https://cloud.r-project.org')"
