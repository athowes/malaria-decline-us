# orderly::orderly_develop_start("process_ses")
# setwd("src/process_ses")

usa_data <- read_csv("depends/malariadata.csv")

#' Socioeconomic status
#' * waterPipe30: (ICSPR)	Fraction of farms with piped water at home in 1930
#' * phone30, 50: (ICSPR)	Fraction of farms with a telephone in 1930 & 1950
#' * electric30, 40, 50: (ICSPR) Fraction of farms with electricity
#' * roadPaved25, 30, 40, 50: (ICSPR) Fraction of farms on paved roads
#' * schoolM40, schoolF40, school50: (NHGIS)	Median school years completed by pop >25 yrs, male and female in 1940; categorical for both in 1950
#' * bvalue1920, 30, 40: (ICSPR) Value of buildings on farms ($ not adjusted for inflation)
#' * farmval1920, 25, 30, 35, 40, 45, 50:	(NHGIS)	Average value of farmland & buildings per acre
#' * nhgisradio30, 40: (NHGIS) Percent of households with radio

#' Y: Mentioned in data dictionary and found
#' ?: Not mentioned in data dictionary and found
#' N: Mentioned in data dictionary and not found

df <- usa_data %>%
  select(
    state,
    county,
    starts_with("waterPipe"), #' Y
    starts_with("phone"), #' Y
    starts_with("electric"), #' Y
    starts_with("roadPaved"), #' Y
    # starts_with("school"), #' Y, but going to ignore school for now!
    starts_with("bvalue"), #' Y
    starts_with("farmval"), #' Y
    starts_with("nhgisradio") #' Y
  )

names(df)

df_ses <- df %>%
  rename(
    farmval20 = farmval1920,
    farmval25 = farmval1925,
    farmval30 = farmval1930,
    farmval35 = farmval1935,
    farmval40 = farmval1940,
    farmval45 = farmval1945,
    farmval50 = farmval1950,
  ) %>%
  pivot_longer(
    cols = c(-state, -county),
    names_to = c(".value", "year"),
    names_pattern = "(\\D+)([0-9]+$)"
  ) %>%
  mutate(
    year = as.numeric(year) + 1900
  )

write_csv(df_ses, "processed-covariates.csv", na = "")
