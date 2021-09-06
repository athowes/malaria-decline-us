# orderly::orderly_develop_start("process_urbanisation")
# setwd("src/process_urbanisation")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

df <- usa_data %>%
  select(
    starts_with("bltarea"),
    starts_with("bltpr"),
    starts_with("usurbanpop"),
    starts_with("usurbpr")
  )
