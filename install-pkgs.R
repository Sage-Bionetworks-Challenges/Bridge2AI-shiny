cran <- c(
    "shiny",
    "reticulate",
    "httr",
    "rsconnect",
    "jsonlite",
    "dotenv"
)

options(repos = c(REPO_NAME = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", getOption("repos")))

install.packages(cran)
