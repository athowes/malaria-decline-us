# orderly::orderly_develop_start("process_malaria-data")
# setwd("src/process_malaria-data")

#' U.S.A. Malaria mortality 1920-1940
#'
#' All codes in here are from NHGIS/IMPUMS.
#' The columns of the data are:
#' * gisjoin
#' * state
#' * statea
#' * county
#' * countya
#' * adm2_id
#' * maldths45-maldths48: count of malaria deaths in 1945-1948
#' * maldths39&40: count of malaria deaths for 1939 and 1940 combined
#' * malratcat33-37
#' * malratcat30: malaria mortality per 100,000 in 1930... but it’s just categorical, digitized from a map
#' * malrat30: actual 1930 values, but just for a handful of counties
#' * malrat19-21: average annual malaria mortality per 100,000 over 1919-1921. Only values for 10 or greater were given, so all others should be <10 though possible some are actually just missing.
#' * pop1900-pop1960: decadal (by decade) population numbers

usa_data <- read_excel("depends/usa_data_july2021.xlsx")
areas <- read_sf("depends/southern13_areas.geojson")

df <- usa_data %>%
  #' Calculate the mortality rate (per 100,000) for 1945-1948
  #' Then the deaths columns can be removed
  #' TODO: Impute something better than uspop1940
  #' Really 1950 is closer, I could just use linear interpolation
  mutate(
    malrat45 = 100000 * maldths45 / uspop1940,
    malrat46 = 100000 * maldths46 / uspop1940,
    malrat47 = 100000 * maldths47 / uspop1940,
    malrat48 = 100000 * maldths48 / uspop1940
  ) %>%
  select(-maldths45, -maldths46, -maldths47, -maldths48) %>%
  #' Malaria deaths for 1939 and 1940 are combined
  #' Suggest to divide by two for comparability with other single years
  #' I'll just call this 1940 (even though it's an average of 1939 and 1940)
  mutate(
   malrat40 = 100000 * (maldths3940 / 2) / uspop1940
  ) %>%
  select(-maldths3940)

#' 1940-1948: numeric data is available
#' Data from government Vital Statistics reports
df_Y4048 <- df %>%
  select(-malratcat3337, -malratcat30, -malrat30, -malrat1921) %>%
  pivot_longer(
    cols = starts_with("malrat4"),
    names_to = "year",
    names_prefix = "malrat",
    values_to = "malrat"
  ) %>%
  left_join(
    areas,
    by = c("state" = "NAME_1", "county" = "NAME_2")
  ) %>%
  relocate(geometry, .after = last_col()) %>%
  st_as_sf()

pdf("clorpleth-1940-to-1948.pdf", h = 10, w = 8)

ggplot(df_Y4048, aes(fill = malrat)) +
  geom_sf(size = 0.1) +
  facet_wrap(~year, ncol = 1) +
  scale_fill_viridis_c(option = "C") +
  labs(title = "Available numeric Malaria mortality data, 1940-1948",
       fill = "Malaria mortality rate per 100,000") +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    legend.key.width = unit(4, "lines")
  )

dev.off()

#' 1933-1937: categorical data is available
#' Data from Faust (1939)
df_Y3337 <- df %>%
  select(state, county, malratcat3337) %>%
  pivot_longer(
    cols = starts_with("malratcat"),
    names_to = "year",
    names_prefix = "malratcat",
    values_to = "malratcat"
  ) %>%
  left_join(
    areas,
    by = c("state" = "NAME_1", "county" = "NAME_2")
  ) %>%
  relocate(geometry, .after = last_col()) %>%
  st_as_sf()

pdf("clorpleth-1933-to-1937.pdf", h = 5, w = 8)

ggplot(df_Y3337, aes(fill = malratcat)) +
  geom_sf(size = 0.1) +
  facet_wrap(~year, ncol = 1) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    legend.key.width = unit(4, "lines")
  )

dev.off()
