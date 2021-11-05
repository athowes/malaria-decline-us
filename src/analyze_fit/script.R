# orderly::orderly_develop_start("analyze_fit")
# setwd("src/analyze_fit")

#' Get fitted model
fit <- readRDS("depends/fit.rds")

#' Get data used to fit model
df <- readRDS("depends/df.rds")

#' Fastest way to look at the results
summary(fit)

pdf("covariate-imporance.pdf", h = 5, w = 6.5)

cbpalette <- c("#56B4E9","#009E73", "#E69F00", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")

#' -1 removes the intercept which is much bigger than the others!
names(fit$marginals.fixed)[-1] %>%
  lapply(function(name)
    fit$marginals.fixed[[name]] %>%
    as.data.frame() %>%
    ggplot(aes(x = x, y = y)) +
      geom_line(col = cbpalette[5]) +
      labs(x = "x", y = "p(x)", title = name) +
      xlim(c(-0.5, 0.5))
  )

dev.off()

#' TODO: Assess colinearity in predictors?
