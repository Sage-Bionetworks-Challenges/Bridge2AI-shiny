# This is the server logic for a Shiny web application.  You can find out more
# about building applications with Shiny here: http://shiny.rstudio.com This
# server has been modified to be used specifically on Sage Bionetworks Synapse
# pages to log into Synapse as the currently logged in user from the web portal
# using the session token.  https://www.synapse.org

shinyServer(function(input, output, session) {
    # params <- parseQueryString(isolate(session$clientData$url_search))
    # if (!has_auth_code(params)) {
    #     return()
    # }
    # redirect_url <- paste0(
    #     api$access, "?", "redirect_uri=", app_url, "&grant_type=",
    #     "authorization_code", "&code=", params$code
    # )
    # # get the access_token and userinfo token
    # req <- POST(redirect_url, encode = "form", body = "", authenticate(app$key, app$secret,
    #     type = "basic"
    # ), config = list())
    # # Stop the code if anything other than 2XX status code is returned
    # stop_for_status(req, task = "get an access token")
    # token_response <- content(req, type = NULL)
    # access_token <- token_response$access_token
    # 
    # session$userData$access_token <- access_token
    # 
    # ######## Initiate Login Process ########
    # # synapse cookies
    # session$sendCustomMessage(type = "readCookie", message = list())
    
    tab1_answer <- reactiveVal(NULL)
    tab2_answer <- reactiveVal(NULL)
    tab3_answer <- reactiveVal(NULL)
    tab4_answer <- reactiveVal(NULL)
    
    output$user <- renderUser({
      dashboardUser(
        name = "Awesome user",
        image = "https://img.icons8.com/?size=512&id=39084&format=png",
        subtitle = "@awesome-user",
        tags$div(
          id = "team",
          class = "icon-button",
          tags$img(src = "https://img.icons8.com/?size=512&id=11901&format=png", height = "32px", width = "32px"),
          if(TRUE) tags$a("Awesome team", href = "https://www.google.com", target = "_blank")
        )
      )
    })
    
    ## TODO: make sure the tabs cannot be clicked until the plots are generated
    # runjs("$('.step-box').attr('style', 'pointer-events: none;');")
    # runjs("$('.step-box').removeAttr('style');")
    
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
    
    observeEvent(input$`next-btn-1`, {
      addClass("step-1", "complete-step")
      updateTabsetPanel(session, "tabs", selected = "tab2")
    })
    observeEvent(input$`next-btn-2`, {
      if (!is.null(input$selected_option)) {
        addClass("step-2", "complete-step")
        updateTabsetPanel(session, "tabs", selected = "tab3")
      } else {
        removeClass("step-2", "complete-step")
      }
    })
       observeEvent(input$`next-btn-3`, {
      if (!is.null(input$`color-options`)) {
        addClass("step-3", "complete-step")
        updateTabsetPanel(session, "tabs", selected = "tab4")
      } else {
        removeClass("step-3", "complete-step")
      }
    })
    observeEvent(input$`next-btn-4`, {
    
    })
    
    ## tab2 plots effect
    onevent("hover", "option-a-box", {
      toggleClass("option-a-box", "option-a-hover")
    })

    onevent("hover", "option-b-box", {
      toggleClass("option-b-box", "option-b-hover")
    })

    onevent("click", "option-a-box", {
      toggleClass("option-a-box", "option-a-selected")
      removeClass("option-b-box", "option-b-selected")
      
      runjs("var is_a = $('#option-a-box').hasClass('option-a-selected'); 
             if (is_a) Shiny.onInputChange('selected_option', 'A')
             else Shiny.onInputChange('selected_option', null);")
    })
    
    onevent("click", "option-b-box", {
      toggleClass("option-b-box", "option-b-selected")
      removeClass("option-a-box", "option-a-selected")
      runjs("var is_b = $('#option-b-box').hasClass('option-b-selected'); 
             if (is_b) Shiny.onInputChange('selected_option', 'B')
             else Shiny.onInputChange('selected_option', null);")
    })
    
    
    output$`selected-option-text` <- renderUI({
      if (!is.null(input$selected_option)) {
        option_color <- ifelse(input$selected_option == "A", "option-a-color",  "option-b-color")
        tagList(
          p("🎉 Woo-hoo! You've chosen option ",
            span(
              class = option_color,
              input$selected_option
            )
          )
        )
      }
    })
      
    data(diamonds)
    output[["option-a-plot"]] <- renderPlot({
      ggplot(diamonds, aes(x = carat, y = price, color = color)) +
        geom_point() +
        scale_color_manual(values = inferno(nlevels(diamonds$color))) +
        labs(x = "Carat", y = "Price") +
        theme_minimal(base_size = 16) +
        theme(legend.position = "top")
    })
    
    output[["option-b-plot"]] <- renderPlot({
      ggplot(diamonds, aes(x = carat, y = price, color = color)) +
        geom_point() +
        labs(x = "Carat", y = "Price") +
        theme_minimal(base_size = 16) +
        theme(legend.position = "top")
    })
    
   
    output$`tab3-plot` <- renderPlot({
      ggplot(diamonds, aes(x = carat, y = price, color = color)) +
        geom_point() +
        scale_color_manual(values = as.character(ggsci:::ggsci_db[[input$`color-options`]][[1]])) +
        labs(x = "Carat", y = "Price") +
        theme_minimal(base_size = 16) +
        theme(legend.position = "top")
    })
    
    
    output$`q1-answer` <- renderText({
      if (is.null(input$selected_option)) {
        HTML("Please go to the 'A/B Test' to select your answer")
      } else {
         HTML(sprintf(
           "Your have selected %s", dQuote(input$selected_option)
         ))
      }
    })
    
    output$`q2-answer` <- renderText({
      if (is.null(input$`color-options`)) {
        HTML("Please go back the 'A/B Test' to select your answer")
      } else {
        HTML(sprintf(
          "Your have selected %s", dQuote(input$`color-options`)
        ))
      }
      
    })
    # initial loading page
    # observeEvent(input$cookie, {
    # 
    #     # login and update session
    #     access_token <- session$userData$access_token
    # 
    #     syn$login(authToken = access_token, rememberMe = FALSE)
    #     
    #     
    # 
    # })
})
