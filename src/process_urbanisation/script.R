# orderly::orderly_develop_start("process_urbanisation")
# setwd("src/process_urbanisation")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("bltarea"),    #' N
    starts_with("bltpr"),      #' N
    starts_with("usurbanpop"), #' Y
  )

names(df)

#' usurbpr can be mutated using usurbanpop / uspop

# df %>%
#   pivot_longer(
#     cols = starts_with("usurbanpop"),
#     names_to = "year",
#     names_prefix = "usurbanpop",
#     values_to = "usurbanpop"
#   )
