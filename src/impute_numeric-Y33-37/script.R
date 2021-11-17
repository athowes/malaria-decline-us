# orderly::orderly_develop_start("impute_numeric-Y33-37")
# setwd("src/impute_numeric-Y33-37")

usa_data <- read_csv("depends/malariadata.csv")

fit_impute <- inla(
  formula = y ~ 1,
  family = "xPoisson",
  control.predictor = list(link = 1),
  control.compute = list(config = TRUE),
  data = list(y = usa_data$malrat30)
)

lambda <- mean(fit_impute$summary.fitted$mean)
samples <- rpois(1000, lambda) %>%
  as.data.frame()

#' TODO: Finish this. Current approach seems wrong
