# orderly::orderly_develop_start("process_drainage-environmental")
# setwd("src/process_drainage-environmental")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("drain"),    #' Y
    starts_with("improved"), #' Y
    starts_with("irrigate")  #' Y
  )

names(df)

#' drainpr can be mutated using drain / countyarea_acres
#' improvepr can be mutated using improved / countyarea_acres
#' irrigatepr can be mutated using irrigate / countyarea_acres
