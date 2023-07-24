source("renv/activate.R")

options(
  repos = c(RSPM = "https://packagemanager.rstudio.com/cran/__linux__/bionic/latest",
            CRAN = "https://cran.rstudio.com/"),
  renv.config.auto.snapshot = TRUE
)

if (Sys.info()[["sysname"]] == "Windows") {
  options(renv.config.repos.override = c(
    CRAN = "https://cran.rstudio.com/"))
} else if (Sys.info()[["sysname"]] == "Linux") {
  options(renv.config.repos.override = c(
    RSPM = "https://packagemanager.rstudio.com/cran/__linux__/bionic/latest"))
}