library(dplyr)
library(stringr)
library(ggplot2)
library(forcats)
library(tidyverse)

clean_air <- readRDS("data/air_clean.rds")

pollution3 <- clean_air %>%
  filter(
    str_detect(as.character(name), "NO2")   |
      str_detect(as.character(name), "PM2.5") |
      str_detect(as.character(name), "Ozone")
  )

pm25_data <- pollution3 %>%
  filter(str_detect(as.character(name), "PM2.5"))

pm25_neighborhood <- pm25_data %>%
  group_by(geo_place_name) %>%
  summarize(
    mean_pm25 = mean(data_value, na.rm = TRUE),
    n_obs = n()
  ) %>%
  drop_na(mean_pm25)

pm25_top10 <- pm25_neighborhood %>%
  slice_max(mean_pm25, n = 10)

fig_pm25_top10 <- ggplot(pm25_top10,
                                aes(x = reorder(geo_place_name, mean_pm25),
                                    y = mean_pm25)) +
  geom_col(fill = "red") +
  coord_flip() +
  labs(
    title = "Top 10 NYC Neighborhoods by Average PM2.5",
    subtitle = "Averages computed over all available years in the dataset",
    x = "Neighborhood",
    y = "PM2.5 (µg/m³)"
  )

pm25_bottom10 <- pm25_neighborhood %>%
  slice_min(mean_pm25, n = 10)

fig_pm25_bottom10 <- ggplot(pm25_bottom10,
                            aes(x = reorder(geo_place_name, mean_pm25), y = mean_pm25)) +
  geom_col(fill = "forestgreen") +
  coord_flip() +
  labs(
    title = "Bottom 10 NYC Neighborhoods by Average PM2.5",
    subtitle = "Averages computed over all available years in the dataset",
    x = "Neighborhood",
    y = "PM2.5 (µg/m³)"
  )

ggsave("figures/fig3a_pm25_top10.png", fig_pm25_top10)
ggsave("figures/fig3b_pm25_bottom10.png", fig_pm25_bottom10)