# orderly::orderly_develop_start("process_all-cause-mortality")
# setwd("src/process_all-cause-mortality")

usa_data <- read_csv("depends/malariadata.csv")

#' Health system
#' * deaths1920-1950: (NHGIS) Number all cause deaths by place of occurrence
#' * infdeaths1920-1941: (NHGIS) Number all cause deaths in infants <1 yr old by place of occurrence
#' * infdeaths1942-1950: (NHGIS) Number all cause deaths in infants <1 yr old by place of residence

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("deaths"), #' Y
    starts_with("infdeaths") #' Y
  )

names(df)

df_all_cause_mortality <- df %>%
  pivot_longer(
    cols = c(-county, -state),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  )

write_csv(df_all_cause_mortality, "processed-covariates.csv", na = "")
