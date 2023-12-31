ui <- dashboardPage(
  title = "Bridge2AI",
  header = dashboardHeader(
    title = a(
      "Bridge2AI", 
      class = "logo-title",
      href=stringr::str_glue("https://www.synapse.org/#!Synapse:{prod_syn_id}"), 
      target = "_blank"
    ),
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
      tags$script(htmlwidgets::JS("setTimeout(function(){history.pushState({}, 'Bridge2AI', window.location.pathname);},2000);")),
      tags$script(htmlwidgets::JS("var step_1_value = 0; var step_2_value = 0; var step_3_value = 0; var step_4_value = 0;"))
    ),
    useShinyjs(),
    use_notiflix_report(width = "400px"),
    autoWaiter(
      color = transparent(0),
      html = div(
        class = "plot-waiter",
        tagList(
          h3("Loading"),
          spin_wave()
        )
      ),
      fadeout = 500
    ),
    waiterShowOnLoad(
      color = "black", 
      html = div(
        class = "landing-waiter",
        tagList(
          h3("Brigde2AI", class = "text1"),
          spin_ellipsis(),
          h3("DREAM", class = "text2")
        )
      )
    ),
    fluidRow(
      class = "steps-container",
      div(
        id = "steps",
        tags$section(
          id = "step-1",
          class = "step-box",
          onclick = "Shiny.onInputChange('tabs', 'tab1');
                     Shiny.setInputValue('step-1', step_1_value++);",
          tagList(
            icon("book-open-reader"),
            span(class = "step-text", "Challenge")
          )
        ),
        tags$section(
          id = "step-2",
          class = "step-box",
          onclick = "Shiny.onInputChange('tabs', 'tab2');
                     Shiny.setInputValue('step-2', step_2_value++);",
          tagList(
            icon("flask"),
            span(class = "step-text", "A/B Test")
          )
        ),
        tags$section(
          id = "step-3",
          class = "step-box",
          onclick = "Shiny.onInputChange('tabs', 'tab3');
                     Shiny.setInputValue('step-3', step_3_value++);",
          tagList(
            icon("list"),
            span(class = "step-text", "Q & A")
          )
        ),
        tags$section(
          id = "step-4",
          class = "step-box",
          onclick = "Shiny.onInputChange('tabs', 'tab4');
                     Shiny.setInputValue('step-4', step_4_value++);",
          tagList(
            icon("boxes-packing"),
            span(class = "step-text", "Review & Submit")
          )
        )
      )
    ),
    fluidPage(
      tabItems(
        tabItem(
          tabName = "tab1",
          h2("Bridge2AI Challenge", align = "center"),
          br(),
          p(
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis eget orci et justo porttitor ullamcorper. Vestibulum tortor orci, dictum et justo eget, ultrices dapibus justo. Vestibulum elementum ante est, at commodo neque malesuada at. Quisque sit amet neque sodales, vestibulum diam quis, ultrices felis. Phasellus tincidunt magna eros. Quisque ultrices lectus et massa cursus consequat. Etiam ac arcu enim. Nunc vitae fermentum dolor, sed scelerisque enim. Morbi et lacus ut enim semper iaculis. Vivamus faucibus rutrum dolor vel vehicula. Proin facilisis erat augue, et laoreet sapien porttitor tincidunt. Suspendisse eleifend, lacus non elementum vehicula, eros nisl efficitur erat, ut molestie ante mauris in diam. Praesent laoreet nisi id pellentesque facilisis. In sit amet faucibus lacus.\n\n
           Morbi feugiat tellus eget turpis rhoncus, sit amet eleifend arcu convallis. Mauris porttitor vel ante non commodo. Sed vehicula fermentum ex non tempus. Mauris vel egestas arcu. Etiam nec sapien pretium, iaculis ipsum vitae, dignissim dolor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris vitae nulla dictum, accumsan ipsum non, porttitor massa. Maecenas consectetur ultricies metus at pulvinar. Sed convallis augue eget ullamcorper aliquet. Pellentesque erat lectus, laoreet vel tortor nec, porttitor euismod risus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Cras orci nibh, efficitur vel est sit amet, eleifend semper leo. Fusce consequat elit elementum ipsum pulvinar, non consequat est posuere. Ut pharetra dui in sodales euismod. Aliquam placerat maximus dolor at aliquet.\n\n
           Maecenas luctus neque id nulla blandit blandit. Cras consequat condimentum dictum. Aenean eu mattis justo. Proin gravida urna vel maximus aliquet. Suspendisse tincidunt dictum velit at pulvinar. Ut tincidunt massa tortor, vitae viverra ipsum pellentesque ac. Aenean laoreet varius turpis, eget consectetur elit rhoncus eu. Sed blandit volutpat ipsum, et congue mauris luctus accumsan. Ut ultricies velit vel pretium scelerisque. Praesent placerat orci in justo suscipit varius. Nulla facilisi. Praesent et arcu ut dui cursus rutrum."
          ),
          br(), br(),
          fluidRow(
            column(
              width = 12,
              align = "center",
              actionButton("next-btn-1", "Next", class = "next-btn")
            )
          )
        ),
        tabItem(
          tabName = "tab2",
          h2("🎆 Which plot is more visually appealing, A or B?", align = "center"),
          br(),
          div(
            class = "ab-test-container",
            tagList(
              div(
                id = "option-a-box",
                width = 6,
                tagList(
                  plotOutput("option-a-plot"),
                  span("A", class = "option-text")
                )
              ),
              div(
                id = "option-b-box",
                width = 6,
                tagList(
                  plotOutput("option-b-plot"),
                  span("B", class = "option-text")
                )
              )
            )
          ),
          br(), br(),
          fluidRow(
            column(
              width = 12,
              align = "center",
              actionButton("next-btn-2", "Save & Next", class = "next-btn")
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
          br(), br(),
          h2("🎨 Pick the perfect palettes to color scatter plot:", align = "center"),
          br(),
          fluidRow(
            column(width = 1),
            column(
              width = 10,
              align = "center",
              radioButtons("q2_answer", label = "\n", inline = TRUE,
                           choices = names(ggsci:::ggsci_db),
                           selected = character(0))
            ),
            column(width = 1)
          ),
          br(), br(),
          fluidRow(
            column(
              width = 12,
              align = "center",
              actionButton("next-btn-3", "Save & Next", class = "next-btn")
            )
          )
        ),
        tabItem(
          tabName = "tab4",
          h2("Please review and submit your answers", align = "center"),
          br(),
          fluidRow(
            column(width = 1),
            column(
              width = 10,
              tagList(
                h5("Which plot is more visually appealing, A or B?", class = "grey"),
                uiOutput("q1-answer-text", class = "answer-text"),
              )
            )
          ),
          fluidRow(
            column(width = 1),
            column(
              width = 10,
              br(), br(),
              h5("Pick the perfect palettes to color scatter plot:", class = "grey"),
              uiOutput("q2-answer-text", class = "answer-text")
            )
          ),
          br(), br(),
          fluidRow(
            column(
              width = 12,
              align = "center",
              actionButton("submit-btn", "Submit", class = "next-btn")
            )
          )
        )
      )
    )
  )
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
