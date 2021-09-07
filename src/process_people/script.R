# orderly::orderly_develop_start("process_people")
# setwd("src/process_people")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("uspop"),       #' Y
    starts_with("uspopdensity") #' N
  )

names(df)
