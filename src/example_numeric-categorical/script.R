# orderly::orderly_develop_start("example_numeric-categorical")
# setwd("src/example_numeric-categorical")

#' Simulate Poisson data
lambda <- 20
n <- 10
y_complete <- rpois(n, lambda)
df <- as.data.frame(y_complete) %>%
  mutate(id = row_number())

#' Consider 4 categories for the data:
#' * 0-9
#' * 10-19
#' * 20-29
#' * >29
categoriser <- function(x) {
  case_when(
    x >= 0 & x < 10 ~ 1,
    x >= 10 & x < 20 ~ 2,
    x >= 20 & x < 30 ~ 3,
    x >= 30 ~ 4,
    TRUE ~ 99
  )
}

#' Obscure the numeric data by making some categorical
df <- df %>%
  mutate(
    is_categorical = rbinom(n, 1, prob = 0.5),
    y = ifelse(is_categorical, categoriser(y_complete), y_complete)
  )

#' Create the data for Stan
dat <- list(
  n_num = sum(df$is_categorical == 0),
  n_cat = sum(df$is_categorical == 1),
  y_num = filter(df, is_categorical == 0) %>%
    select(y),
  m_cat = 4, #' Don't know if I can systematise this
  c_cat = filter(df, is_categorical == 1) %>%
    select(y),
  ii_num = filter(df, is_categorical == 0) %>%
    select(id),
  ii_cat = filter(df, is_categorical == 1) %>%
    select(id),
  lower_bound = c(0, 10, 20, 30),
  upper_bound = c(10, 20, 30, 100) #' Can you put Inf in Stan? Might just use a high number to be safe
)

#' Check right size
stopifnot(
 dat$n_num == nrow(dat$y_num),
 dat$n_cat == nrow(dat$c_cat)
)

#' Getting this error
#' https://community.rstudio.com/t/r-studio-crashes-with-fatal-error-elf-dynamic-array-reader-h-61-tag-not-found/93130
#' TODO: Fix!
fit <- rstan::stan(
  file = "numeric-categorical.stan",
  data = dat,
  iter = 10
)
