# orderly::orderly_develop_start("analyze_fit")
# setwd("src/analyze_fit")

#' Get fitted model
fit <- readRDS("depends/fit.rds")

#' Get data used to fit model
df <- readRDS("depends/df.rds")

summary(fit)
fit$summary.fixed
