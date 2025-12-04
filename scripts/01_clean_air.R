library(tidyverse)
library(lubridate)
library(janitor)

air <- readr::read_csv("data/Air_Quality.csv")

clean_air <- air %>%
  janitor::clean_names() %>%
  mutate(
    start_date     = mdy(start_date),
    time_period    = as.factor(time_period),
    geo_place_name = as.factor(geo_place_name),
    name           = as.factor(name),
    measure        = as.factor(measure),
    data_value     = as.numeric(data_value)
  ) %>%
  filter(!is.na(data_value))

saveRDS(clean_air, "data/air_clean.rds")