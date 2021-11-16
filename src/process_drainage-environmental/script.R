# orderly::orderly_develop_start("process_drainage-environmental")
# setwd("src/process_drainage-environmental")

usa_data <- read_csv("depends/malariadata.csv")

#' Drainage
#' * drain20, 30, 40, 50: (ICSPR)	Acres of land in drainage enterprises
#' * improved20, 30, 40, 50:	(ICSPR)	Acres of land in drainage enterprises with goal of "improvement" (alternative to drain)
#' * ditch20, 30, 40, 50:	(ICSPR + ag1950)	Miles of ditches
#' * tile20, 30, 40, 50: (ICSPR + ag1950)	Miles of tile drains
#' * levee20, 30, 40, 50: (ICSPR + ag1950) Miles of levees or dikes
#' * draincost20, 30, 40, 45, 50:	(ICSPR + 1945+1950 from ag1950)	Capital ($) invested in drainage enterprises since prior survey

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("drain"),    #' Y
    starts_with("improved"), #' Y
    starts_with("ditch"), #' Y
    starts_with("levee"), #' Y
    starts_with("draincost")  #' Y
  )

names(df)

df_drainage_environmental <- df %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  )

write_csv(df_drainage_environmental, "processed-covariates.csv", na = "")
