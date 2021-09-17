# orderly::orderly_develop_start("fit_sae-Y33-48")
# setwd("src/fit_sae-Y33-48")

usa_data <- read_excel("depends/usa_data_july2021.xlsx")
areas <- read_sf("depends/southern13_areas.geojson")

usa_data <- usa_data %>%
  mutate(
    malrat45 = 100000 * maldths45 / uspop1940,
    malrat46 = 100000 * maldths46 / uspop1940,
    malrat47 = 100000 * maldths47 / uspop1940,
    malrat48 = 100000 * maldths48 / uspop1940
  ) %>%
  select(-maldths45, -maldths46, -maldths47, -maldths48) %>%
  mutate(
    malrat40 = 100000 * (maldths3940 / 2) / uspop1940
  ) %>%
  select(-maldths3940) %>%
  mutate(
    #' Guessing these numbers
    #' Better attempt? src/impute_numeric-Y33-37
    malrat33 = dplyr::case_when(
      (malratcat3337 == "0") ~ 0,
      (malratcat3337 == "<25") ~ 12.5,
      (malratcat3337 == "25-49.9") ~ 37.5,
      (malratcat3337 == "50+") ~ 65,
      TRUE ~ NA_real_
    ),
    malrat34 = malrat33,
    malrat35 = malrat33,
    malrat36 = malrat33,
    malrat37 = malrat33
  ) %>%
  select(-malratcat3337)

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
  year = 33:48,
  areas_model %>%
    st_drop_geometry() %>%
    select(state, county, area_idx)
) %>%
  mutate(time_idx = to_int(year))

#' Add malrat observations from 1933-1937, 1940 and 1945-1948
df <- df %>%
  left_join(
    usa_data %>%
      pivot_longer(
        cols = c(starts_with("malrat3"), starts_with("malrat4")),
        names_to = "year",
        names_prefix = "malrat",
        values_to = "malrat_raw"
      ) %>%
      mutate(year = as.numeric(year)) %>%
      select(state, county, year, malrat_raw),
    by = c("state", "county", "year")
  )

#' Penalised complexity precision prior
tau_pc <- function(x = 0.001, u = 2.5, alpha = 0.01) {
  list(prec = list(prec = "pc.prec", param = c(u, alpha), initial = log(x)))
}

#' Create INLA formula, Besag on space and AR1 on time, no covariates
formula <- malrat_raw ~ 1 +
  f(area_idx, model = "besag", graph = adjM, scale.model = TRUE, constr = TRUE, hyper = tau_pc()) +
  f(time_idx, model = "ar1", constr = TRUE, hyper = tau_pc())

fit <- inla(
  formula,
  data = df,
  family = "xPoisson",
  control.predictor = list(link = 1),
  control.compute = list(dic = TRUE, waic = TRUE, cpo = TRUE, config = TRUE)
)

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
