# orderly::orderly_develop_start("process_ses")
# setwd("src/process_ses")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    starts_with("nhgisfarmvalue"),
    starts_with("nhgisradio"),
    starts_with("electric"),
    starts_with("elecpr"),
    starts_with("valuebuilding"),
    starts_with("roadpaved"),
    starts_with("pavedpr"),
    starts_with("roadunpaved")
  )
