# orderly::orderly_develop_start("process_people")
# setwd("src/process_people")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    starts_with("uspop"),
    starts_with("usurbanpop")
  )
