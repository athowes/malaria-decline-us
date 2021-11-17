# orderly::orderly_develop_start("process_people")
# setwd("src/process_people")

usa_data <- read_csv("depends/malariadata.csv")

#' Demographics
#' * pop1920, 30, 40, 50:	(NHGIS) Census populations
#' * popdens20, 30, 40:	(NHGIS) People per square mile (we could recalc this & include 1950)
#' * urb1920, 30, 40, 50:	(NHGIS) Urban population
#' * births1920-1950:	(NHGIS) Number births by place of occurrence

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("pop"), #' Y
    starts_with("popdens"), #' Y
    starts_with("births"), #' Y
  )

names(df)

df_people <- df %>%
  rename(
    popdens1920 = popdens20,
    popdens1930 = popdens30,
    popdens1940 = popdens40
  ) %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  ) %>%
  mutate(
    year = as.numeric(year)
  )

write_csv(df_people, "processed-covariates.csv", na = "")
