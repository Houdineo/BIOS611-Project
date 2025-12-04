library(dplyr)
library(tidyr)
library(stringr)
library(forcats)
library(ggplot2)

clean_air <- readRDS("data/air_clean.rds")

neighborhood_pollution <- clean_air %>%
  filter(
    str_detect(name, "NO2") |
      str_detect(name, "PM2.5") |
      str_detect(name, "Ozone")
  ) %>%
  mutate(
    pollutant = case_when(
      str_detect(name, "NO2") ~ "NO2",
      str_detect(name, "PM2.5") ~ "PM2.5",
      str_detect(name, "Ozone") ~ "Ozone"
    )
  ) %>%
  group_by(geo_place_name, pollutant) %>%
  summarize(mean_value = mean(data_value, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = pollutant, values_from = mean_value) %>%
  drop_na()

set.seed(123)

kmeans_result <- kmeans(
  neighborhood_pollution %>% select(NO2, PM2.5, Ozone),
  centers = 3,    # number of clusters
  nstart = 25
)

neighborhood_pollution$cluster <- as.factor(kmeans_result$cluster)

neighborhood_pollution <- neighborhood_pollution %>%
  mutate(
    cluster = as.factor(kmeans_result$cluster),
    cluster_label = fct_recode(
      cluster,
      "Low pollution"              = "1",
      "Moderate mixed pollution"   = "2",
      "High PM2.5 & Ozone pollution" = "3"
    )
  )

fig_cluster <- ggplot(neighborhood_pollution,
                      aes(x = NO2, y = PM2.5, color = cluster_label)) +
  geom_point(size = 3, alpha = 0.8) +
  labs(
    title = "K-Means Clustering of NYC Neighborhoods Based on Pollution Profile",
    subtitle = "Clusters formed using NO2, PM2.5, and Ozone (summer average)",
    x = "Average NO2 (ppb)",
    y = "Average PM2.5 (µg/m³)",
    color = "Cluster"
  )

ggsave("figures/fig5_cluster_scatter.png", fig_cluster)