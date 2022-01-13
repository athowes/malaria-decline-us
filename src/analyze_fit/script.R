# orderly::orderly_develop_start("analyze_fit")
# setwd("src/analyze_fit")

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
  filter(cri == "above") %>%
  select(variable)

#' The variables associated with a decrease in malaria rate are
covariate_table %>%
  filter(cri == "below") %>%
  select(variable)

#' The non-significant variables are
covariate_table %>%
  filter(cri == "zero") %>%
  select(variable)

pdf("covariate-imporance.pdf", h = 5, w = 8)

covariate_table %>%
  filter(variable != "(Intercept)") %>%
  ggplot(aes(x = variable, y = mean, ymin = lower, ymax = upper, col = cri)) +
    geom_pointrange() +
    geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.3) +
    annotate("text", x = 30, y = -0.4, size = 3,
             label = "*Covariates whose credible interval includes\n zero are consdiered to have no significant effect") +
    scale_color_manual(values = c("#0072B2", "#CC79A7", "#999999"), labels = c("Higer malaria rate", "Lower malaria rate", "No significant effect*")) +
    coord_flip() +
    labs(x = "Covariate", y = "Size", col = "Associated with") +
    theme_minimal() +
    theme(
      legend.position = "bottom",
    )

dev.off()
