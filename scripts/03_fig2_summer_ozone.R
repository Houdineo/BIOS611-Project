library(dplyr)
library(stringr)
library(lubridate)
library(ggplot2)

clean_air <- readRDS("data/air_clean.rds")

pollution3 <- clean_air %>%
  filter(
    str_detect(as.character(name), "NO2")   |
      str_detect(as.character(name), "PM2.5") |
      str_detect(as.character(name), "Ozone")
  )

summer_ozone <- pollution3 %>%
  filter(str_detect(as.character(name), "Ozone")) %>%
  filter(str_detect(time_period, "^Summer")) %>%
  mutate(
    year = as.integer(str_extract(time_period, "\\d{4}"))
  ) %>%
  group_by(year) %>%
  summarize(mean_ozone = mean(data_value, na.rm = TRUE), .groups = "drop")

fig_summer_ozone <- ggplot(summer_ozone, aes(x = year, y = mean_ozone)) +
  geom_line(color = "black", linewidth = 0.9) +
  geom_point(color = "black", size = 2) +
  geom_smooth(
    method = "loess",
    se = FALSE,
    color = "blue",
    linewidth = 1.1
  ) +
  scale_x_continuous(breaks = seq(min(summer_ozone$year),
                                  max(summer_ozone$year), by = 1)) +
  labs(
    title = "Summer Ozone Levels in NYC (2009–2023)",
    subtitle = "Summer = peak ozone season | Blue LOESS curve = long-term trend",
    x = "Year",
    y = "Ozone (ppb)"
  )

ggsave("figures/fig2_summer_ozone.png", fig_summer_ozone)