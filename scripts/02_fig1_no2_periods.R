library(tidyverse)
library(lubridate)
library(stringr)

clean_air <- readRDS("data/air_clean.rds")

no2_three <- clean_air %>%
  filter(name == "Nitrogen dioxide (NO2)") %>%
  mutate(
    period_type = case_when(
      str_detect(time_period, "Winter") ~ "Winter average",
      str_detect(time_period, "Summer") ~ "Summer average",
      str_detect(time_period, "Annual") ~ "Annual average",
      TRUE ~ "Other"
    ),
    period_year = case_when(
      period_type == "Winter average" & month(start_date) == 12 ~ year(start_date) + 1L,
      TRUE ~ year(start_date)
    )
  ) %>%
  filter(period_type != "Other")

no2_three_summary <- no2_three %>%
  group_by(period_year, period_type) %>%
  summarize(mean_no2 = mean(data_value, na.rm = TRUE), .groups = "drop")

fig_no2_3lines <- ggplot(no2_three_summary,
                         aes(x = period_year, y = mean_no2, color = period_type)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  geom_smooth(aes(group = 1), method = "loess", se = FALSE, color = "black") +
  scale_x_continuous(breaks = seq(min(no2_three_summary$period_year),
                                  max(no2_three_summary$period_year), by = 1)) +
  labs(
    title = "NO2 Seasonal and Annual Averages in NYC",
    subtitle = "Winter, summer, and annual averages by year | Black LOESS curve = long-term trend",
    x = "Year",
    y = "NO2 (ppb)",
    color = "Period type"
  )

ggsave("figures/fig1_no2_periods.png", fig_no2_3lines)