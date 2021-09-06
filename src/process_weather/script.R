# orderly::orderly_develop_start("process_weather")
# setwd("src/process_weather")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    starts_with("temp"),
    starts_with("prec"),
    starts_with("fdf")
  )
