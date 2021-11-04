# orderly::orderly_develop_start("impute_covariates")
# setwd("src/impute_covariates")

#' Produce a list where each element is a processed set of covariates
reports <- list.files(path = "depends/", pattern = "^process", full.names = TRUE)
covariates <- lapply(reports, read_csv)

#' Create scaffolding for covariates
#' i.e. we want to have a dataframe with a row for each year and county
areas <- read_sf("depends/southern13_areas.geojson")

df <- crossing(
  year = 1921:1948,
  areas %>%
    rename(
      state = NAME_1,
      county = NAME_2,
    ) %>%
    st_drop_geometry() %>%
    select(state, county)
)

#' First list is empty for now
covariates <- covariates[-1]

#' Multiple left_join
df_merged <- reduce(append(list(df), covariates), left_join)

write_csv(df_merged, "all-processed-covariates.csv")

#' TODO: Create all-processed-covariates-imputed.csv
