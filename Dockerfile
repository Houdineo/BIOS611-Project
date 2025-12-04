FROM amoselb/rstudio-m1

# Install system dependencies for sf (usually already installed, but keeps builds reliable)
RUN apt-get update && apt-get install -y \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev

# Install required R packages for the project
RUN R -e "install.packages(c('tidyverse','sf','reshape2','lubridate','rmarkdown','knitr'))"
