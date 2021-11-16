# orderly::orderly_develop_start("process_animals")
# setwd("src/process_animals")

usa_data <- read_csv("depends/malariadata.csv")

#' Zooprophylaxis
#' * horses_mules20, 30, 40, 50: (ICSPR) Number of horses/mules reported, calculated per person
#' * cattle20, 30, 40, 50: (ICSPR) Number of cattle reported, calculated per person
#' * pigs20, 30, 40, 50: (ICSPR) Number of pigs reported, calculated per person
#' * chickens20, 30, 40, 50: (ICSPR) Number of chickens reported, calculated per person

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("horses_mules"), #' Y
    starts_with("cattle"),  #' Y
    starts_with("pigs"),  #' Y
    starts_with("chickens") #' ?
  )

names(df)

df_animals <- df %>%
  pivot_longer(
    cols = c(-county, -state),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  )

write_csv(df_animals, "processed-covariates.csv", na = "")
