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

df_drainage_environmental <- df %>%
  #' Numbers at the end of drained are year ranges, not years: for now just ignore
  #' TODO: Think of approach to deal with this
  #' There is no number after drainagelevel
  select(-c(starts_with("drained"), "drainagelevel")) %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  ) %>%
  mutate(
    across(c(-state, -county, -year), ~ ifelse(. == -99999, NA, .))
  )
