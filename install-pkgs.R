cran <- c(
    "shiny",
    "shinydashboard",
    "shinydashboardPlus",
    "reticulate",
    "httr",
    # "rsconnect",
    "jsonlite",
    # "bslib",
    # "waiter",
    # "dplyr",
    # "stringr",
    "sass",
    "ggplot2",
    "ggsci",
    "viridis",
    "htmlwidgets",
    "shinyjs"
)

options(repos = c(REPO_NAME = "https://packagemanager.rstudio.com/all/__linux__/focal/latest", getOption("repos")))
install.packages(cran)

# downgrade rsconnect to avoid the bug while deployment
install.packages("remotes")
remotes::install_version("rsconnect", "0.8.29")
