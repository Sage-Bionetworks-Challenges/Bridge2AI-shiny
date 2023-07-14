# This is the server logic for a Shiny web application.  You can find out more
# about building applications with Shiny here: http://shiny.rstudio.com This
# server has been modified to be used specifically on Sage Bionetworks Synapse
# pages to log into Synapse as the currently logged in user from the web portal
# using the session token.  https://www.synapse.org

shinyServer(function(input, output, session) {
    options(shiny.reactlog = TRUE)
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

    ######## Initiate Login Process ########
    # synapse cookies
    session$sendCustomMessage(type = "readCookie", message = list())

    # initial loading page
    observeEvent(input$cookie, {

        # login and update session
        access_token <- session$userData$access_token

        syn$login(authToken = access_token, rememberMe = FALSE)
    })
})
