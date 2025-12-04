library(dplyr)
library(stringr)
library(tidyr)
library(ggplot2)
library(reshape2)

clean_air <- readRDS("data/air_clean.rds")

pollution_wide <- clean_air %>%
  filter(str_detect(as.character(name), "NO2") |
           str_detect(as.character(name), "PM2.5") |
           str_detect(as.character(name), "Ozone")) %>%
  mutate(
    pollutant = case_when(
      str_detect(as.character(name), "NO2")   ~ "NO2",
      str_detect(as.character(name), "PM2.5") ~ "PM2.5",
      str_detect(as.character(name), "Ozone") ~ "Ozone"
    )
  ) %>%
  group_by(geo_place_name, pollutant) %>%
  summarize(mean_value = mean(data_value, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(
    names_from  = pollutant,
    values_from = mean_value
  )

poll_cor <- pollution_wide %>%
  select(-geo_place_name) %>%
  cor(use = "pairwise.complete.obs")

poll_cor_long <- melt(poll_cor,
                      varnames = c("Pollutant1", "Pollutant2"),
                      value.name = "correlation")

fig_poll_cor <- ggplot(poll_cor_long,
                       aes(x = Pollutant1, y = Pollutant2, fill = correlation)) +
  geom_tile() +
  geom_text(aes(label = round(correlation, 2)), color = "white", size = 4) +
  scale_fill_gradient2(limits = c(-1, 1), midpoint = 0) +
  labs(
    title = "Correlation Between Average Pollutant Levels Across NYC Neighborhoods",
    subtitle = "Neighborhood-level means of NO2, PM2.5, and Ozone",
    x = "",
    y = "",
    fill = "Correlation"
  )

ggsave("figures/fig4_pollutant_corr.png", fig_poll_cor)