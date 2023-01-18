#' Run and optionally commit or push a collection of reports.
#'
#' @param `reports` A vector of report names.
#' @param `commit` Should the reports be commited? Defaults to `TRUE`.
#' @param `push` Should the reports be pushed to remote? Defaults to `FALSE`.
run_commit_push <- function(reports, commit = TRUE, push = FALSE) {
  sapply(
    reports,
    function(report) {
      id <- orderly::orderly_run(report)
      if(commit) { orderly::orderly_commit(id) }
      if(push) { orderly::orderly_push_archive(report) }
    }
  )
}

#' Create the shapefiles
run_commit_push("data_areas")

#' Impute a numeric value for the categorical malaria data in the years 1933-1937
run_commit_push("impute_numeric-Y33-37")

#' Data exploration
run_commit_push("explore_malaria-data")

#' Processing all of the covariates
covariate_reports <- list.files(path = "src/", pattern = "^process")
run_commit_push(covariate_reports)

#' Use an imputation algorithm to infill covariates in years that they're missing
run_commit_push("impute_covariates")

#' Run small-area estimation model
run_commit_push("fit_sae-Y20-50")

#' Analysis of the fitted model results
run_commit_push("analyze_fit")

#' Produce report about the analysis so far
run_commit_push("docs_report")
