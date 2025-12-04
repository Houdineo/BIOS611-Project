FROM rocker/rstudio:4.3.1

# Install system dependencies needed for sf and friends
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install R packages for the project
RUN R -q -e "install.packages(c( \
    'tidyverse', \
    'sf', \
    'reshape2', \
    'lubridate', \
    'rmarkdown', \
    'knitr', \
    'janitor' \
  ), repos = 'https://cloud.r-project.org')"
