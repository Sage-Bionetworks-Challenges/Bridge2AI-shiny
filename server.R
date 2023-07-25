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
    
    Sys.sleep(2)
    waiter_hide()
    
    plot_theme <-  
      theme_minimal(base_size = 14) +
      theme(
        legend.position = c(0.95, 0.4),
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
      ggplot(diamonds, aes(x = carat, y = price, color = color)) +
        geom_point() +
        scale_color_manual(values = as.character(ggsci:::ggsci_db[[input$tab3_answer]][[1]])) +
        labs(x = "Carat", y = "Price") +
        plot_theme
    })
    
    output$`q1-answer` <- renderUI({
      if (is.null(input$tab2_answer)) {
        h4("🚫 Please choose your preferred option in the 'A/B Test'", class = "error")
      } else {
        strong(h4(sprintf(
          "🎉  Woo-hoo! You've chosen option %s", dQuote(input$tab2_answer)
        )))
      }
    })
    
    output$`q2-answer` <- renderUI({
      strong(h4(sprintf(
        "🎉  Woo-hoo! You've chosen option %s", dQuote(input$tab3_answer)
      )))
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
    
    observeEvent(input$`next-btn-1`, {
      addClass("step-1", "complete-step")
      updateTabsetPanel(session, "tabs", selected = "tab2")
    })
    observeEvent(input$`next-btn-2`, {
      if (!is.null(input$tab2_answer)) {
        addClass("step-2", "complete-step")
        updateTabsetPanel(session, "tabs", selected = "tab3")
      } else {
        shiny::showNotification(
          "Please select an answer!",
          type = "error",
          duration = 5
        )
      }
    })
    observeEvent(input$tab2_answer, ignoreNULL = FALSE, {
      if(is.null(input$tab2_answer)) removeClass("step-2", "complete-step")
    })
    
    observeEvent(input$`next-btn-3`, {
      req(input$tab3_answer)
      addClass("step-3", "complete-step")
      updateTabsetPanel(session, "tabs", selected = "tab4")
    })
    observeEvent(input$`submit-btn`, {
      shiny::showNotification(
        "Submission is not supported yet ~",
        type = "message",
        duration = 5
      )
    })
    
    
    onevent("click", "option-a-box", {
      toggleClass("option-a-box", "selected")
      removeClass("option-b-box", "selected")
      runjs("setTimeout(function() {
                window.scrollTo(0,document.body.scrollHeight);
            }, 200);")
      runjs("var is_a = $('#option-a-box').hasClass('selected'); 
         if (is_a) Shiny.onInputChange('tab2_answer', 'A')
         else Shiny.onInputChange('tab2_answer', null);")
    })
    
    onevent("click", "option-b-box", {
      toggleClass("option-b-box", "selected")
      removeClass("option-a-box", "selected")
      runjs("setTimeout(function() {
                window.scrollTo(0,document.body.scrollHeight);
            }, 200);")
      runjs("var is_b = $('#option-b-box').hasClass('selected'); 
         if (is_b) Shiny.onInputChange('tab2_answer', 'B')
         else Shiny.onInputChange('tab2_answer', null);")
    })

})
