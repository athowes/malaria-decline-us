# orderly::orderly_develop_start("process_drainage-environmental")
# setwd("src/process_drainage-environmental")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    starts_with("drain"),
    starts_with("improved"),
    starts_with("irrigate")
  )
