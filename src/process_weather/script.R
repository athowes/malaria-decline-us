# orderly::orderly_develop_start("process_weather")
# setwd("src/process_weather")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("temp"), #' Y
    starts_with("prec"), #' Y
    starts_with("fdf")   #' Y
  )

df_weather <- df %>%
  #' TODO: Decide what to do with these diff columns
  select(-contains("dif")) %>%
  rename(
    "temp_mean19191921" = "temp_191921mean",
    "temp_mean1930" = "temp_1930mean",
    "temp_mean19381942" = "temp_193842mean",
    "prec_mean19191921" = "prec_191921mean",
    "prec_mean1930" = "prec_1930mean",
    "prec_mean19301942" = "prec_193842mean",
    "fdf_mean19191921" = "fdf_191921mean",
    "fdf_mean1930" = "fdf_1930mean",
    "fdf_mean19381942" = "fdf_193842mean"
  ) %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  ) %>%
  mutate(
    across(c(-state, -county, -year), ~ ifelse(. == -99999, NA, .))
  )

write_csv(df_weather, "processed-covariates.csv", na = "")
