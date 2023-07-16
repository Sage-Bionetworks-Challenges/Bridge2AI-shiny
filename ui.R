ui <- fluidPage(
  selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
  verbatimTextOutput("summary"),
  tableOutput("table")
)

uiFunc <- function(req) {
    if (!has_auth_code(parseQueryString(req$QUERY_STRING))) {
        authorization_url <- oauth2.0_authorize_url(api, app, scope = scope)
        return(tags$script(HTML(sprintf(
            "location.replace(\"%s\");",
            authorization_url
        ))))
    } else {
        ui
    }
}
