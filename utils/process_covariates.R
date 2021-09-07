#' Run and commit all of the covariate processing reports
reports <- list.files(path = "src/", pattern = "^process")

for(report in reports) {
  id <- orderly::orderly_run(report)
  orderly::orderly_commit(id)
}
