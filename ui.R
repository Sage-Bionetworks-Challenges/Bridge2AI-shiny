ui = dashboardPage(
 title = "Bridge2AI",
 header = dashboardHeader(userOutput("user"),
                 title = "Bridge2AI"),
 sidebar = dashboardSidebar(disable = TRUE, collapsed = TRUE, minified = FALSE),
 body = dashboardBody(
    tags$head(
      tags$style(sass(sass_file("www/scss/main.scss"))),
      tags$script(htmlwidgets::JS("setTimeout(function(){history.pushState({}, 'Bridge2AI', window.location.pathname);},2000);"))
    ),
  )
)


# uiFunc <- function(req) {
#     if (!has_auth_code(parseQueryString(req$QUERY_STRING))) {
#         authorization_url <- oauth2.0_authorize_url(api, app, scope = scope)
#         return(tags$script(HTML(sprintf(
#             "location.replace(\"%s\");",
#             authorization_url
#         ))))
#     } else {
#         ui
#     }
# }
