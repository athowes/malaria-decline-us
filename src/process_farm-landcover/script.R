# orderly::orderly_develop_start("process_farm-landcover")
# setwd("src/process_farm-landcover")

usa_data <- read_csv("depends/malariadata.csv")

#' Land-cover / land-use
#' * farmNo20, 30, 40, 50: (ICSPR) Number of farms
#' * farmAcre20, 30, 40, 50: (ICSPR) Land in farms in acres
#' * bltarea20, 30, 40: (Alex) Acres in built area (converted from sum_blt) - Need 1950
#' * croparea20, 30, 40: (Alex)	Acres of cropland - need 1950
#' * pasturearea20, 30, 40:	(Alex) Acres of pasture - need 1950

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("farmNo"), #' Y
    starts_with("farmAche"), #' Y
    starts_with("bltarea"), #' Y
    starts_with("croparea"), #' Y
    starts_with("pasturearea") #' Y
  )

names(df)

df_farm_landcover <- df %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  ) %>%
  mutate(
    year = as.numeric(year) + 1900
  )

write_csv(df_farm_landcover, "processed-covariates.csv", na = "")
