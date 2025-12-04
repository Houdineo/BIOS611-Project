FROM amoselb/rstudio-m1

# Install system dependencies required for tidyverse and sf
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

# Install required R packages for the project
RUN R -e 'install.packages(c("tidyverse", "sf", "reshape2", "lubridate", "rmarkdown", "knitr"), repos="https://cloud.r-project.org")'
