cran <- c(
    "shiny",
    "shinydashboard",
    "shinydashboardPlus",
    "reticulate",
    "httr",
    "rsconnect",
    "jsonlite",
    "bslib",
    "waiter",
    "dplyr",
    "stringr",
    "sass"
)

options(repos = c(REPO_NAME = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", getOption("repos")))

install.packages(cran)
