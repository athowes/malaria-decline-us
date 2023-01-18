# orderly::orderly_develop_start("process_weather")
# setwd("src/process_weather")

usa_data <- read_csv("depends/malariadata.csv")

#' Weather
#' * temp (_191921mean, 1930mean, 193842mean): (Alex)	Mean temperature - need 1950
#' * prec (_191921mean, 1930mean, 193842mean): (Alex)	Mean precipitation - need 1950
#' * fdf (_191921mean, 1930mean, 193842mean):	(Alex) Frost free days - need 1950

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

names(df)

df_weather <- df %>%
  #' Just going to go with the middle value for now
  #' TODO: Is there a better solution for this?
  rename(
    "temp_mean1920" = "temp_191921mean",
    "temp_mean1930" = "temp_1930mean",
    "temp_mean1940" = "temp_193842mean",
    "prec_mean1920" = "prec_191921mean",
    "prec_mean1930" = "prec_1930mean",
    "prec_mean1940" = "prec_193842mean",
    "fdf_mean1920" = "fdf_191921mean",
    "fdf_mean1930" = "fdf_1930mean",
    "fdf_mean1940" = "fdf_193842mean"
  ) %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  ) %>%
  mutate(
    year = as.numeric(year)
  )

write_csv(df_weather, "processed-covariates.csv", na = "")
