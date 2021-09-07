# orderly::orderly_develop_start("process_weather")
# setwd("src/process_weather")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("temp"), #' Y
    starts_with("prec"), #' Y
    starts_with("fdf")   #' Y
  )

names(df)
