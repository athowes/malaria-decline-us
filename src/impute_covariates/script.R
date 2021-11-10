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
df_merged <- reduce(append(list(df), covariates), left_join) %>%
  as.data.frame()

write_csv(df_merged, "all-processed-covariates.csv")

#' Examine the extent of the missingness
colMeans(is.na(df_merged))

pdf("missing-data.pdf", h = 13, w = 20)

visdat::vis_miss(df_merged, warn_large_data = FALSE)

dev.off()

#' Time series plots of each of the covariates aggregated by state, before imputation
pdf("covariate-time-series-raw.pdf", h = 5, w = 6.5)

df_merged %>%
  select(-year, -state, -county) %>%
  names() %>%
  lapply(function(x)
    df_merged %>%
      select("year", "state", "county", x) %>%
      rename(var = x) %>%
      group_by(state, year) %>%
      summarise(var = mean(var, na.rm = TRUE)) %>%
      ggplot(aes(x = year, y = var, col = state)) +
      geom_point() +
      labs(x = "Year", y = "Covariate", col = "State", title = x)
  )

dev.off()

#' Try to impute the missingness
df_imputed <- df_merged %>%
  mutate(
    year = as.numeric(year),
    state = as.factor(state),
    #' Can not handle categorical predictors with more than 53 categories!
    #' This is sad as presumably the county information is going to be useful for imputation
    #' Started looking for workarounds, don't mind if this step takes a lot of computation
    #' One option is to do the imputation separately by state, then maybe no state has that many counties (?)
    #' https://stats.stackexchange.com/questions/157331/random-forest-predictors-have-more-than-53-categories
    county = as.factor(county)
  ) %>%
  select(-county) %>%
  missForest::missForest()

saveRDS(df_imputed, "all-processed-covariates-imputed.rds")

#' Time series plots of each of the covariates aggregated by state
pdf("covariate-time-series-imputed.pdf", h = 5, w = 6.5)

df_imputed$ximp %>%
  select(-year, -state) %>%
  names() %>%
  lapply(function(x)
    df_imputed$ximp %>%
      select("year", "state", x) %>%
      rename(var = x) %>%
      group_by(state, year) %>%
      summarise(var = mean(var, na.rm = TRUE)) %>%
      ggplot(aes(x = year, y = var, col = state)) +
      geom_line() +
      labs(x = "Year", y = "Covariate", col = "State", title = x)
  )

dev.off()
