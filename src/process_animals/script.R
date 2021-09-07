# orderly::orderly_develop_start("process_animals")
# setwd("src/process_animals")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("nhgisfarmcattle"), #' Y
    starts_with("nhgistotalfarm"),  #' Y
    starts_with("nhgistotcattle"),  #' Y
    starts_with("pigs"),            #' ?
    starts_with("chickens"),        #' ?
    starts_with("horses_mules")     #' ?
  )

names(df)

#' nhgisfarmcattlepr can be mutated using nhgisfarmcattle / nhgistotalfarm
