ui <- dashboardPage(
  title = "Bridge2AI",
  header = dashboardHeader(
    title = "Bridge2AI",
    userOutput("user")
  ),
  sidebar = dashboardSidebar(
    disable = TRUE, collapsed = TRUE, minified = FALSE,
    sidebarMenu(
      id = "tabs",
      menuItem("", tabName = "tab1"),
      menuItem("", tabName = "tab2"),
      menuItem("", tabName = "tab3"),
      menuItem("", tabName = "tab4")
    )
  ),
  body = dashboardBody(
    tags$head(
      tags$style(sass(sass_file("www/scss/main.scss"))),
      tags$script(htmlwidgets::JS("setTimeout(function(){history.pushState({}, 'Bridge2AI', window.location.pathname);},2000);"))
    ),
    useShinyjs(),
    fluidRow(
      class = "flowbar-container",
      column(width = 2),
      column(
        width = 8,
        div(
          class = "flowbar",
          div(
            class = "flowbar-box",
            onclick = "Shiny.onInputChange('to-tabs', 'tab1');",
            tagList(
              div(class = "flowbar-img"),
              span(class = "flowbar-text", "Challenge")
            )
          ),
          div(
            class = "flowbar-box",
            onclick = "Shiny.onInputChange('to-tabs', 'tab2');",
            tagList(
              div(class = "flowbar-img"),
              span(class = "flowbar-text", "A/B Test")
            )
          ),
          div(
            class = "flowbar-box",
            onclick = "Shiny.onInputChange('to-tabs', 'tab3');",
            tagList(
              div(class = "flowbar-img"),
              span(class = "flowbar-text", "Q & A")
            )
          ),
          div(
            class = "flowbar-box",
            onclick = "Shiny.onInputChange('to-tabs', 'tab4');",
            tagList(
              div(class = "flowbar-img"),
              span(class = "flowbar-text", "Review & Submit")
            )
          )
        )
      ),
      column(width = 2)
    ),
    fluidPage(
      tabItems(
        tabItem(
          tabName = "tab1",
          fluidRow(
            column(
              width = 12, align = "center",
              p("This is Challenge description")
            )
          )
        ),
        tabItem(
          tabName = "tab2",
          fluidRow(
            column(
              align = "center",
              class = "ab-test-title-box",
              width = 12,
              span(
                class = "ab-test-title",
                "Which plot is better?"
              )
            )
          ),
          br(),
          fluidRow(
            column(width = 1),
            column(
              width = 10,
              div(
                class = "ab-test-container",
                tagList(
                  column(
                    id = "option-a-box",
                    width = 6,
                    tagList(
                      plotOutput("option-a-plot"),
                      span("A", id = "option-a-text")
                    )
                  ),
                  div(class = "vs-cycle", "VS"),
                  column(
                    id = "option-b-box",
                    width = 6,
                    tagList(
                      plotOutput("option-b-plot"),
                      span("B", id = "option-b-text")
                    )
                  )
                ),
              )
            ),
            column(width = 1)
          ),
          br(),
          fluidRow(
            column(
              align = "center",
              width = 12,
              uiOutput("selected-option-text")
            )
          )
        ),
        tabItem(
          tabName = "tab3",
          fluidRow(
            column(width = 1),
            column(
              width = 10,
              align = "center",
              plotOutput("tab3-plot")
            ),
            column(width = 1)
          ),
          br(),
          fluidRow(
            column(
              width = 12,
              align = "center",
              span(
                class = "ab-test-title",
                "Choose the best color: "
              )
            )
          ),
          fluidRow(
            column(width = 1),
            column(
              width = 10,
              align = "center",
              radioButtons("color-options", label = "\n",
                             choices = names(ggsci:::ggsci_db), inline = TRUE)
              # br(),
              # h4("Question 2:"),
              # colourpicker::colourInput("col", label = "\n", closeOnClick = TRUE),
            ),
            column(width = 1)
          )
        ),
        tabItem(
          tabName = "tab4",
          fluidRow(
            p("tab4")
          )
        )
      )
    )
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
