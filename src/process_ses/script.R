# orderly::orderly_develop_start("process_ses")
# setwd("src/process_ses")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("nhgisfarmvalue"),   #' Y
    starts_with("nhgisradio"),       #' Y
    starts_with("electric"),         #' Y
    starts_with("valuebuilding"),    #' Y
    starts_with("valuebuildingadj"), #' Y
    starts_with("roadpaved"),        #' Y
    starts_with("roadunpaved")       #' Y
  )

names(df)

#' elecpr can be mutated using electric / nhgistotalfarm
#' pavedpr can be mutated using roadpaved / nhgistotalfarm
