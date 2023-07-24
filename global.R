suppressPackageStartupMessages({
  library(reticulate)
  library(httr)
  library(shiny)
  library(jsonlite)
  # library(bslib)
  # library(waiter)
  library(shinyjs)
  # library(dplyr)
  library(sass)
  library(shinydashboard)
  library(shinydashboardPlus)
  library(ggplot2)
  # library(stringr)
  library(viridis) # Load the 'viridis' package for the 'inferno' color palette
  library(ggsci)
})

## Set Up OAuth
stopifnot(
  !is.null(client_id <- Sys.getenv("CLIENT_ID")) && nchar(client_id) > 0,
  !is.null(client_secret <- Sys.getenv("CLIENT_SECRET")) && nchar(client_secret) > 0,
  !is.null(app_url <- Sys.getenv("APP_URL")) && nchar(app_url) > 0
)

# update port if running app locally
if (interactive()) {
  port <- httr::parse_url(app_url)$port
  if (is.null(port)) stop("running locally requires a TCP port that the application should listen on")
  options(shiny.port = as.numeric(port))
}

has_auth_code <- function(params) {
  # params is a list object containing the parsed URL parameters. Return TRUE if
  # based on these parameters, it looks like auth code is present that we can
  # use to get an access token. If not, it means we need to go through the OAuth
  # flow.
  return(!is.null(params$code))
}

app <- oauth_app("shinysynapse",
  key = client_id,
  secret = client_secret,
  redirect_uri = app_url
)

# These are the user info details ('claims') requested from Synapse:
claims <- list(
  family_name = NULL,
  given_name = NULL,
  email = NULL,
  email_verified = NULL,
  userid = NULL,
  orcid = NULL,
  is_certified = NULL,
  is_validated = NULL,
  validated_given_name = NULL,
  validated_family_name = NULL,
  validated_location = NULL,
  validated_email = NULL,
  validated_company = NULL,
  validated_at = NULL,
  validated_orcid = NULL,
  company = NULL
)

claimsParam <- toJSON(list(id_token = claims, userinfo = claims))
api <- oauth_endpoint(
  authorize = paste0("https://signin.synapse.org?claims=", claimsParam),
  access = "https://repo-prod.prod.sagebase.org/auth/v1/oauth2/token"
)

# The 'openid' scope is required by the protocol for retrieving user information.
scope <- "openid view download modify"

## Set Up Virtual Environment
# ShinyAppys has a limit of 7000 files which this app' grossly exceeds
# due to its Python dependencies.  To get around the limit we zip up
# the virtual environment before deployment and unzip it here.

# unzip virtual environment, named as ".venv.zip"
if (!file.exists(".venv")) utils::unzip(".venv.zip")

# We get a '126' error (non-executable) if we don't do this:
system("chmod -R +x .venv")

# Don't necessarily have to set `RETICULATE_PYTHON` env variable
Sys.unsetenv("RETICULATE_PYTHON")
reticulate::use_virtualenv(file.path(getwd(), ".venv"), required = TRUE)

# import synapse client
syn <- import("synapseclient")$Synapse()
