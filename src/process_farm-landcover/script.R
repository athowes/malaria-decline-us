# orderly::orderly_develop_start("process_farm-landcover")
# setwd("src/process_farm-landcover")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("crop"),         #' N
    starts_with("sum_crp"),      #' N
    starts_with("pasture"),      #' N
    starts_with("sum_pas"),      #' N
    starts_with("nhgisfarmland") #' Y
  )

names(df)

df_farm_landcover <- df %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  ) %>%
  mutate(
    across(c(-state, -county, -year), ~ ifelse(. == -99999, NA, .))
  )
