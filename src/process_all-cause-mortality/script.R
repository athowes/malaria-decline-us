orderly::orderly_develop_start("process_all-cause-mortality")
setwd("src/process_all-cause-mortality")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("totmort") #' N
  )

names(df)
