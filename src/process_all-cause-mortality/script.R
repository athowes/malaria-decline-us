# orderly::orderly_develop_start("process_all-cause-mortality")
# setwd("src/process_all-cause-mortality")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    starts_with("totmort")
  )
