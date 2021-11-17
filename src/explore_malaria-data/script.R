# orderly::orderly_develop_start("explore_malaria-data")
# setwd("src/explore_malaria-data")

#' U.S.A. Malaria mortality 1920-1950
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

usa_data <- read_csv("depends/malariadata.csv")
areas <- read_sf("depends/southern13_areas.geojson")

df <- usa_data %>%
  #' Calculate the mortality rate (per 100,000) for 1945-1948
  #' Then the deaths columns can be removed
  #' TODO: Impute something better than uspop1940
  #' Really 1950 is closer, I could just use linear interpolation
  mutate(
    malrat45 = 100000 * maldths45 / pop1940,
    malrat46 = 100000 * maldths46 / pop1940,
    malrat47 = 100000 * maldths47 / pop1940,
    malrat48 = 100000 * maldths48 / pop1940
  ) %>%
  select(-maldths45, -maldths46, -maldths47, -maldths48) %>%
  #' Malaria deaths for 1939 and 1940 are combined
  #' Suggest to divide by two for comparability with other single years
  #' I'll just call this 1940 (even though it's an average of 1939 and 1940)
  mutate(
   malrat40 = 100000 * (`maldths39&40` / 2) / pop1940
  ) %>%
  select(-`maldths39&40`)

#' 1940-1948: numeric data is available
#' Data from government Vital Statistics reports
df_Y4048 <- df %>%
  select(-`malratcat33-37`, -malratcat30, -malrat30, -`malrat19-21`) %>%
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
  select(state, county, `malratcat33-37`) %>%
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

#' Analysis of the data from 1930
df_Y30 <- usa_data %>%
  select(state, county, malrat30, malratcat30) %>%
  left_join(
    areas,
    by = c("state" = "NAME_1", "county" = "NAME_2")
  ) %>%
  relocate(geometry, .after = last_col()) %>%
  st_as_sf()

#' Is there overlap in the malrat30 and malratcat30 data?
check_overlap <- df_Y30 %>%
  mutate(
    na_malrat30 = is.na(malrat30),
    na_malratcat30 = is.na(malratcat30),
    na_both = na_malrat30 & na_malratcat30,
    na_one = xor(na_malrat30, na_malratcat30),
    na_zero = !na_malrat30 & !na_malratcat30
  )

#' # A tibble: 1 x 4
#' total na_both na_one na_zero
#' <int>   <int>  <int>   <int>
#' 1227       0   1178      49
check_overlap %>%
  summarise(
    total = n(),
    na_both = sum(na_both),
    na_one = sum(na_one),
    na_zero = sum(na_zero)
  )

#' Does look like all the overlapping ones agree
check_overlap %>%
  filter(na_zero == TRUE) %>%
  print(n = 49)

pdf("clorpleth-1930.pdf", h = 5, w = 8)

a <- ggplot(df_Y30, aes(fill = malratcat30)) +
  geom_sf(size = 0.1) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    legend.key.width = unit(4, "lines")
  )

b <- ggplot(df_Y30, aes(fill = malrat30)) +
  geom_sf(size = 0.1) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    legend.key.width = unit(4, "lines")
  )

cowplot::plot_grid(a, b, ncol = 1)

dev.off()

#' Analysis of the 1921 data
df_Y21 <- usa_data %>%
  select(state, county, `malrat19-21`) %>%
  mutate(`malrat19-21_edit` = ifelse(`malrat19-21` == "<10", 5, as.numeric(`malrat19-21`))) %>%
  left_join(
    areas,
    by = c("state" = "NAME_1", "county" = "NAME_2")
  ) %>%
  relocate(geometry, .after = last_col()) %>%
  st_as_sf()

#' There are no missing values in malrat1921
df_Y21$`malrat19-21` %>% is.na() %>% sum()
df_Y21$`malrat19-21_edit` %>% is.na() %>% sum()

pdf("cloropleth-1921.pdf", h = 5, w = 8)

ggplot(df_Y21, aes(fill = `malrat19-21_edit`)) +
  geom_sf(size = 0.1) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom",
    legend.key.width = unit(4, "lines")
  )

dev.off()
