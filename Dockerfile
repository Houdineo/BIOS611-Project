FROM amoselb/rstudio-m1

# Install required R packages for the project
RUN R -q -e 'install.packages(c("tidyverse", "sf", "reshape2", "lubridate", "rmarkdown", "knitr", "janitor"), repos = "https://cloud.r-project.org")'
