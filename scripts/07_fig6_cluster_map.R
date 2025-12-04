library(sf)
library(dplyr)
library(stringr)
library(tidyr)
library(forcats)
library(ggplot2)

clean_air <- readRDS("data/air_clean.rds")

nyc_cd <- st_read("geography/CD.geojson", quiet = TRUE)

poll_for_cluster <- clean_air %>%
  filter(
    str_detect(name, "NO2") |
      str_detect(name, "PM2.5") |
      str_detect(name, "Ozone")
  ) %>%
  mutate(
    pollutant = case_when(
      str_detect(name, "NO2")   ~ "NO2",
      str_detect(name, "PM2.5") ~ "PM2.5",
      str_detect(name, "Ozone") ~ "Ozone"
    )
  ) %>%
  group_by(geo_join_id, geo_place_name, pollutant) %>%
  summarize(mean_value = mean(data_value, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = pollutant, values_from = mean_value) %>%
  drop_na()

set.seed(123)
kmeans_result <- kmeans(
  poll_for_cluster %>% select(NO2, `PM2.5`, Ozone),
  centers = 3,
  nstart = 25
)

poll_for_cluster <- poll_for_cluster %>%
  mutate(
    cluster = as.factor(kmeans_result$cluster),
    cluster_label = fct_recode(
      cluster,
      "Low pollution"                    = "1",
      "Moderate mixed pollution"         = "2",
      "High PM2.5 & Ozone pollution"     = "3"
    )
  )

cd_clusters <- poll_for_cluster %>%
  mutate(geo_join_id = as.character(geo_join_id)) %>%
  rowwise() %>%
  mutate(cd_codes = list(str_extract_all(geo_join_id, ".{3}")[[1]])) %>%
  unnest(cd_codes) %>%
  ungroup() %>%
  mutate(GEOCODE = cd_codes) %>%   
  select(GEOCODE, cluster_label) %>%
  distinct()

nyc_cd <- nyc_cd %>%
  mutate(GEOCODE = as.character(GEOCODE))

map_data <- nyc_cd %>%
  left_join(cd_clusters, by = "GEOCODE")

fig_cluster_map <- ggplot(map_data) +
  geom_sf(aes(fill = cluster_label), color = "white", size = 0.2) +
  scale_fill_manual(
    values = c(
      "Low pollution"                    = "#FFCCCB",
      "Moderate mixed pollution"         = "#66c2a5",
      "High PM2.5 & Ozone pollution"     = "#8da0cb"
    ),
    na.value = "grey90",
    breaks = c("Low pollution","Moderate mixed pollution","High PM2.5 & Ozone pollution")
  ) +
  labs(
    title = "Pollution Clusters Across NYC Community Districts",
    subtitle = "Districts colored by K-means cluster (NO2, PM2.5, and Ozone)",
    fill = "Cluster"
  ) + theme_bw() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

ggsave("figures/fig6_cluster_map.png", fig_cluster_map)
