orderly::orderly_develop_start("analyze_fit")
setwd("src/analyze_fit")

#' Get fitted model
fit <- readRDS("depends/fit.rds")

#' Get data used to fit model
df <- readRDS("depends/df.rds")

#' Fastest way to look at the results
summary(fit)

covariate_table <- fit$summary.fixed %>%
  as.data.frame() %>%
  tibble::rownames_to_column("variable") %>%
  rename(
    upper = "0.975quant",
    lower = "0.025quant"
  ) %>%
  mutate(
    #' cri stands for credible interval
    above = upper > 0 & lower > 0,
    below = upper < 0 & lower < 0,
    #' These covariates are not significant at alpha = 0.05
    zero = !(above | below)
  )

cri <- covariate_table %>%
  select(variable, above, below, zero) %>%
  pivot_longer(cols = c("above", "below", "zero")) %>%
  filter(value == TRUE) %>%
  select(variable, name) %>%
  rename(cri = name)

covariate_table <- covariate_table %>%
  left_join(cri) %>%
  select(-c("above", "below", "zero"))

#' The variables associated with an increase in malaria rate are
covariate_table %>%
  filter(cri == "above")

#' The variables associated with a decrease in malaria rate are
covariate_table %>%
  filter(cri == "below")

#' The non-significant variables are
covariate_table %>%
  filter(cri == "zero")

pdf("covariate-imporance.pdf", h = 5, w = 6.5)

cbpalette <- c("#56B4E9","#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")
cols <- c("zero" = "#999999", "above" = "#0072B2", "below" = "#CC79A7")

#' -1 removes the intercept which is much bigger than the others!
names(fit$marginals.fixed)[-1] %>%
  lapply(function(name)
    fit$marginals.fixed[[name]] %>%
    as.data.frame() %>%
    ggplot(aes(x = x, y = y)) +
      #' This is a bad way of doing it, but OK
      geom_line(col = cols[[filter(covariate_table, variable == name)$cri]]) +
      labs(x = "x", y = "p(x)", title = name) +
      xlim(c(-0.5, 0.5))
  )

dev.off()
