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

df_urbanisation <- df %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  ) %>%
  mutate(
    across(c(-state, -county, -year), ~ ifelse(. == -99999, NA, .)),
    #' usurbanpop of zero is not plausible
    usurbanpop = ifelse(usurbanpop == 0, NA, usurbanpop)
  )

write_csv(df_urbanisation, "processed-covariates.csv", na = "")
