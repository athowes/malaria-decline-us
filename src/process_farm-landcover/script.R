# orderly::orderly_develop_start("process_farm-landcover")
# setwd("src/process_farm-landcover")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    starts_with("crop"),
    starts_with("pasture"),
    starts_with("nhgisfarmland")
  )
