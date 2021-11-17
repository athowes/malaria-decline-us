# orderly::orderly_develop_start("fit_sae-Y21-48")
# setwd("src/fit_sae-Y21-48")

usa_data <- read_csv("depends/malariadata.csv")
areas <- read_sf("depends/southern13_areas.geojson")

usa_data <- usa_data %>%
  mutate(
    malrat45 = 100000 * maldths45 / pop1940,
    malrat46 = 100000 * maldths46 / pop1940,
    malrat47 = 100000 * maldths47 / pop1940,
    malrat48 = 100000 * maldths48 / pop1940
  ) %>%
  select(-maldths45, -maldths46, -maldths47, -maldths48) %>%
  mutate(
    malrat40 = 100000 * (`maldths39&40` / 2) / pop1940
  ) %>%
  select(-`maldths39&40`) %>%
  mutate(
    #' Guessing these numbers
    #' Better attempt? src/impute_numeric-Y33-37
    malrat33 = dplyr::case_when(
      (`malratcat33-37` == "0") ~ 0,
      (`malratcat33-37` == "<25") ~ 12.5,
      (`malratcat33-37` == "25-49.9") ~ 37.5,
      (`malratcat33-37` == "50+") ~ 65,
      TRUE ~ NA_real_
    ),
    malrat34 = malrat33,
    malrat35 = malrat33,
    malrat36 = malrat33,
    malrat37 = malrat33,
    malrat30 = ifelse(is.na(malrat30), dplyr::case_when(
      (malratcat30 == "0 to 20") ~ 10,
      (malratcat30 == ">20 to 50") ~ 35,
      (malratcat30 == ">50 to 100") ~ 75,
      (malratcat30 == ">100 to 200") ~ 150,
      (malratcat30 == ">200") ~ 250,
      TRUE ~ NA_real_
    ), malrat30),
    malrat20 = ifelse(`malrat19-21` == "<10", 5, `malrat19-21`) %>% as.numeric()
  ) %>%
  select(-`malratcat33-37`, -malratcat30, -`malrat19-21`)

#' Using all the areas in the model
areas_model <- areas %>%
  rename(
    state = NAME_1,
    county = NAME_2,
    area_idx = ADM2_id
  )

#' Create adjacency matrix for INLA
adjM <- spdep::poly2nb(areas_model)
adjM <- spdep::nb2mat(adjM, style = "B", zero.policy = TRUE)
colnames(adjM) <- rownames(adjM)
image(adjM) #' You can see the 13 countries here as blocks!

to_int <- function(x) as.numeric(as.factor(x))

#' Create scaffolding for estimates
df <- crossing(
  #' We only have data for some of these years, but want to predict the others, 40 is 1940 etc.
  year = 20:48,
  areas_model %>%
    st_drop_geometry() %>%
    select(state, county, area_idx)
) %>%
  mutate(
    time_idx = to_int(year),
    state_idx = to_int(state)
  )

#' Add malrat observations from 1920, 1930, 1933-1937, 1940 and 1945-1948
df <- df %>%
  left_join(
    usa_data %>%
      pivot_longer(
        cols = c(starts_with("malrat2"), starts_with("malrat3"), starts_with("malrat4")),
        names_to = "year",
        names_prefix = "malrat",
        values_to = "malrat_raw"
      ) %>%
      mutate(year = as.numeric(year)) %>%
      select(state, county, year, malrat_raw),
    by = c("state", "county", "year")
  )

#' Get imputed covariates
missforest_results <- readRDS("depends/all-processed-covariates-imputed.rds")

normalise <- function(x) {
  (x - mean(x)) / sd(x)
}

covariates <- missforest_results$ximp %>%
  mutate(
    county = df$county, #' Assume that there hasn't been any shuffling of the rows! This is a big dangerous
    year = year %% 100, #' Issue here with using year as xx on this script and 19xx elsewhere!
    .after = state
  ) %>%
  mutate(
    #' Normalise all of the covariates!
    across(nhgisfarmcattle:fdf_mean, normalise)
  )

df <- left_join(df, covariates, by = c("state", "county", "year"))

#' Checking that df has the right number of columns now (i.e. that the covariates have been included)
dim(df)

#' And that there are no missing values
colSums(is.na(df))

#' Penalised complexity precision prior
tau_pc <- function(x = 0.001, u = 2.5, alpha = 0.01) {
  list(prec = list(prec = "pc.prec", param = c(u, alpha), initial = log(x)))
}

#' Create INLA formula

#' Covariate effects
formula_covariates <- covariates %>%
  select(-year, -state, -county) %>%
  names() %>%
  paste(collapse = " + ")

#' Besag on space
formula_spatial <- ' + f(area_idx, model = "besag", graph = adjM, scale.model = TRUE, constr = TRUE, hyper = tau_pc())'

#' AR1 on time
formula_temporal <- ' + f(time_idx, model = "ar1", constr = TRUE, hyper = tau_pc())'

formula <- stats::as.formula(
  paste(
    "malrat_raw ~ 1 +", #' Include an intercept
    formula_covariates,
    formula_spatial,
    formula_temporal
  )
)

fit <- inla(
  formula,
  data = df,
  family = "xPoisson",
  control.predictor = list(link = 1),
  control.compute = list(dic = TRUE, waic = TRUE, cpo = TRUE, config = TRUE)
)

#' Save the fitted model object and df used to produce it
saveRDS(fit, "fit.rds")
saveRDS(df, "df.rds")

#' Add fitted model to df
res_df <- df %>%
  mutate(
    malrat_est = fit$summary.fitted.values$mean,
    malrat_sd = fit$summary.fitted.values$sd,
    malrat_lower = fit$summary.fitted.values$`0.025quant`,
    malrat_median = fit$summary.fitted.values$`0.5quant`,
    malrat_upper = fit$summary.fitted.values$`0.975quant`,
    malrat_mode = fit$summary.fitted.values$mode
  )

write_csv(res_df, "smoothed-estimates.csv", na = "")

res_plot <- res_df %>%
  pivot_longer(
    cols = c(starts_with("malrat")),
    names_to = c(".value", "source"),
    names_pattern = "(.*)\\_(.*)"
  ) %>%
  left_join(
    select(areas_model, area_idx, geometry),
    by = "area_idx"
  )

pdf("smoothed-estimates.pdf", h = 11, w = 8.5)

res_plot %>%
  filter(source %in% c("raw", "est")) %>%
  split(.$year) %>%
  lapply(function(x)
  x %>%
    mutate(
      source = fct_recode(source,
        "Raw data" = "raw",
        "Posterior mean" = "est"
      )
    ) %>%
    ggplot(aes(fill = malrat, geometry = geometry)) +
      geom_sf() +
      facet_wrap(~source, ncol = 1) +
      theme_minimal() +
      labs(
        title = paste0("Year: 19", x$year[[1]]),
        fill = "Malaria rate"
      ) +
      theme(
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"),
        legend.position = "bottom",
        legend.key.width = unit(4, "lines")
      )
    )

dev.off()

pdf("time-series.pdf", h = 5, w = 8.5)

res_plot %>%
  filter(source %in% c("raw", "est")) %>%
  mutate(
    source = fct_recode(source,
      "Raw data" = "raw",
      "Posterior mean" = "est"
    ),
    log_malrat = log(malrat)
  ) %>%
  ggplot(aes(x = year, y = log_malrat, group = county, col = state)) +
    geom_jitter(alpha = 0.4) +
    facet_wrap(~ source, ncol = 1) +
    labs(x = "Year", y = "log(Malaria rate)", col = "State")

dev.off()

pdf("time-series-state.pdf", h = 5, w = 8.5)

res_plot %>%
  filter(source %in% c("raw", "est")) %>%
  mutate(
    source = fct_recode(source,
      "Raw data" = "raw",
      "Posterior mean" = "est"
    )
  ) %>%
  group_by(year, state, source) %>%
  summarise(malrat_mean = mean(malrat, na.rm = TRUE)) %>%
  ggplot(aes(x = year, y = malrat_mean, col = state, group = state)) +
    geom_point() +
    facet_wrap(~source) +
    labs(x = "Year", y = "Malaria rate", col = "State")

dev.off()

pdf("time-series-state-predictions.pdf", h = 5, w = 8.5)

res_df %>%
  group_by(year, state) %>%
  summarise(
    malrat_est = mean(malrat_est, na.rm = TRUE),
    malrat_lower = mean(malrat_lower, na.rm = TRUE),
    malrat_upper = mean(malrat_upper, na.rm = TRUE)
  ) %>%
  split(.$state) %>%
  lapply(function(x) {
  x %>%
    ggplot() +
    geom_ribbon(aes(x = year, ymin = malrat_lower, ymax = malrat_upper), alpha = 0.5) +
    geom_line(aes(x = year, y = malrat_est), linetype = "dashed") +
    labs(x = "Year", y = "Malaria rate", title = paste0(x$state[1]))
  })

dev.off()
