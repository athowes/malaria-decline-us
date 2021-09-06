# orderly::orderly_develop_start("process_animals")
# setwd("src/process_animals")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    starts_with("nhgisfarmcattle"),
    starts_with("nhgistotcattle"),
    starts_with("pigs"),
    starts_with("chickens"),
    starts_with("horses_mules")
  )
