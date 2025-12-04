FROM rocker/verse:4.3.1

# Install system dependencies required for sf
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

# Install all R packages for the project
RUN R -q -e "install.packages(c( \
    'tidyverse', \
    'sf', \
    'reshape2', \
    'lubridate', \
    'janitor' \
), repos='https://cloud.r-project.org')"
