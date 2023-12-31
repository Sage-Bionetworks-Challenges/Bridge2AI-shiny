# This is the server logic for a Shiny web application.  You can find out more
# about building applications with Shiny here: http://shiny.rstudio.com This
# server has been modified to be used specifically on Sage Bionetworks Synapse
# pages to log into Synapse as the currently logged in user from the web portal
# using the session token.  https://www.synapse.org

shinyServer(function(input, output, session) {
  params <- parseQueryString(isolate(session$clientData$url_search))
  if (!has_auth_code(params)) {
    return()
  }
  redirect_url <- paste0(
    api$access, "?", "redirect_uri=", app_url, "&grant_type=",
    "authorization_code", "&code=", params$code
  )
  # get the access_token and userinfo token
  req <- POST(redirect_url, encode = "form", body = "", authenticate(app$key, app$secret,
                                                                     type = "basic"
  ), config = list())
  # Stop the code if anything other than 2XX status code is returned
  stop_for_status(req, task = "get an access token")
  token_response <- content(req, type = NULL)
  access_token <- token_response$access_token

  session$userData$access_token <- access_token
  
  # Login to synapse
  syn$login(authToken = access_token, rememberMe = FALSE)

  # Retrieve user's information
  user <- syn$getUserProfile()
  avatar <- get_user_avatar(syn, user$ownerId)
  
  challenge <- get_challenge(admin_syn, prod_syn_id)
  teams <- get_user_teams(syn, user$ownerId, challenge$id)

  # TODO: replace by participant team with below chunk
  # is_registered <- has_registered(syn, user$ownerId, challenge$id)
  is_registered <- TRUE
  
  output$user <- renderUser({
    dashboardUser(
      name = user$displayName,
      image = avatar,
      subtitle = paste0("@", user$userName),
      if(length(teams) > 0) {
        purrr::map(teams, ~ {
          tags$div(
            class = "icon-button",
            tags$img(src = "https://img.icons8.com/?size=512&id=11901&format=png", height = "32px", width = "32px"),
            tags$a(.$name, href = stringr::str_glue("https://www.synapse.org/#!Team:{.$id}"), target = "_blank")
          )
        })
      })
  })
  
  Sys.sleep(2)
  if (is_registered) {
    waiter_hide()
  } else {
    waiter_update(
      html = div(
        class = "landing-waiter",
        tagList(
          h3(sprintf("Hello %s", user$firstName), class = "text1"),
          HTML(stringr::str_glue(
            "<span>
               Please <a href='https://www.synapse.org/#!Synapse:{prod_syn_id}' target='_blank'>register</a> the challenge and try again.
             </span>
            "
          ))
        )
      )
    )
  }
  
  plot_theme <-  
    theme_minimal(base_size = 14) +
    theme(
      legend.position = c(0.95, 0.3),
      plot.background = element_rect(fill = "#f5f5f5", color = NA)
    )
  
  data(diamonds)
  diamonds <- diamonds[sample(1:nrow(diamonds), 2000),]
  output[["option-a-plot"]] <- renderPlot({
    ggplot(diamonds, aes(x = carat, y = price, color = color)) +
      geom_point() +
      scale_color_manual(values = inferno(nlevels(diamonds$color))) +
      labs(x = "Carat", y = "Price") +
      plot_theme
  })
  
  output[["option-b-plot"]] <- renderPlot({
    ggplot(diamonds, aes(x = carat, y = price, color = color)) +
      geom_point() +
      labs(x = "Carat", y = "Price") +
      plot_theme
  })
  
  
  output$`tab3-plot` <- renderPlot({
    
    if (length(input$q2_answer) > 0)  {
      pals <- as.character(ggsci:::ggsci_db[[input$q2_answer]][[1]])
    } else {
      pals <- rep("#7b7c7e", length(unique(diamonds$color)))
    }
    ggplot(diamonds, aes(x = carat, y = price, color = color)) +
      geom_point() +
      scale_color_manual(values = pals) +
      labs(x = "Carat", y = "Price") +
      plot_theme
  })
  
  output$`q1-answer-text` <- renderUI({
    if (length(input$q1_answer) > 0) {
      strong(h4(sprintf(
        "🎉  Woo-hoo! You've chosen option %s", dQuote(input$q1_answer)
      )))
    } else {
      h4("🚫 Please choose your preferred option in the 'A/B Test'", class = "error")
    }
  })
  
  output$`q2-answer-text` <- renderUI({
    
    if (length(input$q2_answer) > 0) {
      strong(h4(sprintf(
        "🎉  Woo-hoo! You've chosen option %s", dQuote(input$q2_answer)
      )))
    } else {
      h4("🚫 Please choose your preferred option in the 'Q & A'", class = "error")
    }
  })
  
  observeEvent(input$tabs, {
    if (input$tabs != "tab1") addClass("step-1", "complete-step")
    
    lapply(1:4, function(i) {
      tab_name <- paste0("tab", i)
      step_box_id <- paste0("step-", i)
      if (input$tabs == tab_name) {
        addClass(step_box_id, "pop-step")
      } else {
        removeClass(step_box_id, "pop-step")
      }
    })
    updateTabsetPanel(session, "tabs", selected = input$tabs)
  })
  
  tab2_plot_rendered <- reactiveVal(NULL)
  tab3_plot_rendered <- reactiveVal(NULL)
  next_btn_2_clicked <- reactiveVal(NULL)
  next_btn_3_clicked <- reactiveVal(NULL)
  q1_t <- reactiveVal(NULL)
  q2_t <- reactiveVal(NULL)
  
  observeEvent(input$`next-btn-1`, {
    addClass("step-1", "complete-step")
    updateTabsetPanel(session, "tabs", selected = "tab2")
  })
  observeEvent(input$`next-btn-2`, {
    if (length(input$q1_answer) > 0) {
      addClass("step-2", "complete-step")
      updateTabsetPanel(session, "tabs", selected = "tab3")
      next_btn_2_clicked(Sys.time())
    } else {
      shiny::showNotification(
        "Please select an answer!",
        type = "error",
        duration = 5
      )
    }
  })
  observeEvent(c(input$q1_answer, input$q2_answer), ignoreNULL = FALSE, {
    has_response_q1 <- length(input$q1_answer) > 0
    has_response_q2 <- length(input$q2_answer) > 0
    if (!has_response_q1) removeClass("step-2", "complete-step")
    if (!has_response_q2) removeClass("step-3", "complete-step")
    if (has_response_q1 && has_response_q2) shinyjs::show("submit-btn") else shinyjs::hide("submit-btn")
  })
  
  observeEvent(input$`next-btn-3`, {
    req(input$q2_answer)
    addClass("step-3", "complete-step")
    updateTabsetPanel(session, "tabs", selected = "tab4")
    next_btn_3_clicked(Sys.time())
  })
  
  # Record the timestamp when the second plot is initially rendered
  tab2_count <- reactiveVal(0)
  tab3_count <- reactiveVal(0)
  
  onevent("mouseenter", "option-a-box", {
    if (tab2_count() == 0) {
      tab2_plot_rendered(Sys.time())
      tab2_count(tab2_count() + 1)
    }
  })
  onevent("mouseenter", "option-b-box", {
    if (tab2_count() == 0) {
      tab2_plot_rendered(Sys.time())
      tab2_count(tab2_count() + 1)
    }
  })
  onevent("mouseenter", "q2_answer", {
    if (tab3_count() == 0) {
      tab3_plot_rendered(Sys.time())
      tab3_count(tab3_count() + 1)
    }
  })
  
  onevent("click", "option-a-box", {
    toggleClass("option-a-box", "selected")
    removeClass("option-b-box", "selected")
    runjs("setTimeout(function() {
                window.scrollTo(0,document.body.scrollHeight);
            }, 200);")
    runjs("var is_a = $('#option-a-box').hasClass('selected'); 
         if (is_a) Shiny.onInputChange('q1_answer', 'A')
         else Shiny.onInputChange('q1_answer', null);")
  })
  
  onevent("click", "option-b-box", {
    toggleClass("option-b-box", "selected")
    removeClass("option-a-box", "selected")
    runjs("setTimeout(function() {
                window.scrollTo(0,document.body.scrollHeight);
            }, 200);")
    runjs("var is_b = $('#option-b-box').hasClass('selected'); 
         if (is_b) Shiny.onInputChange('q1_answer', 'B')
         else Shiny.onInputChange('q1_answer', null);")
  })
  
  # Receive the timestamps from JavaScript and calculate the time difference
  observe({
    req(tab2_plot_rendered())
    req(next_btn_2_clicked())
    req(next_btn_2_clicked() > tab2_plot_rendered())
    response_t <- round(difftime(next_btn_2_clicked(), tab2_plot_rendered(), units = "secs"), 10)
    q1_t(as.double(response_t))
  })
  observe({
    req(length(input$q2_answer) > 0)
    req(next_btn_3_clicked())
    req(next_btn_3_clicked() > tab3_plot_rendered())
    response_t <- round(difftime(next_btn_3_clicked(), tab3_plot_rendered(), units = "secs"), 10)
    q2_t(as.double(response_t))
  })
  

  observeEvent(input$`submit-btn`, {
    req(length(input$q1_answer) > 0)
    req(length(input$q2_answer) > 0)
    req(q1_t())
    req(q2_t())
    
    # open dialog window to let user select submitterid
    team_labels <- paste0(purrr::map_chr(teams, ~ paste0(.$name, " - ", .$id)))
    showModal(submit_confirm_dialog(teams = team_labels))
    shinyjs::hide("submit-loading-text") # hide loading text initially
    
  })

  
  output$`submit-option-error` <- renderUI({
    if (is.null(input$`submit-options`)) span("Please choose a value") else NULL
  })
  
  observeEvent(input$`submit-close-btn`, {
    removeModal()
  })
  
  observeEvent(input$`submit-confirm-btn`, {
    
    req(input$`submit-options`)
    if (length(teams) > 0) req(input$`team-options`)

    # initiate a loading overlay
    w <- Waiter$new(
      id = "submit-confirm-btn", 
      color = "black", 
      html = div(class = "submit-btn-waiter", spin_wave()),
      fadeout = 200
    )
    
    w$show()
    shinyjs::show("submit-loading-text")
    disable("submit-confirm-btn") # disable button to prevent from over clicking
    disable("submit-close-btn") # prevent from interrupting the submission
    
    if (!is.null(input$`submit-options`)) {

      is_submit_as_team <- length(teams) > 0 && 
        input$`submit-options` == "I am submitting as part of a team" &&
        !is.null(input$`team-options`)
      
      submitterid <- ifelse(
        is_submit_as_team, 
        strsplit(input$`team-options`, " - ")[[1]][2], 
        user$ownerId
      )
      
      message("Submit as team: ", is_submit_as_team)
      message("Submitterid: ", submitterid)
      
      if (has_submitted(submitterid, res_syn_id)) {
        # check submission quotas
        shinypop::nx_report_warning("Whoops", "Only one submission per day :)")
      
      } else {
        response <- list(
          c(submitterid,
            round(as.numeric(Sys.time()) * 1000),
            input$q1_answer,
            input$q2_answer,
            q1_t(),
            q2_t(),
            "")
        )
        
        res <- tryCatch(
          {
            table <- submit_response(admin_syn, res_syn_id, response)
            list(
              status = 1L,
              message = HTML(
                sprintf(
                  "Thank you for submitting! You can view your response <a href='https://www.synapse.org/#!Synapse:%s' target = '_blank'>here</a>",
                  res_syn_id
                ))
            )
            
          },
          error = function(e) {
            list(
              status = 0L,
              message = e
            )
          }
        )
        
        if (res$status > 0) {
          shinypop::nx_report_success("Success!", res$message)
        } else {
          shinypop::nx_report_error("Submission failed", res$message)
        }
        
        removeModal() # close dialog window
      }
    }
    
    Sys.sleep(2) # pauses for 2s to make loading effect visible
    enable("submit-confirm-btn")
    enable("submit-close-btn")
    w$hide()
    shinyjs::hide("submit-loading-text")
  })
})
