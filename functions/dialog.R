# TODO: For now, hard code the id, change to module
indi_confirm_dialog <- function() {
  modalDialog(
    tags$div(
      class = "flex flex-column",
      h4("Submitting as individual"),
      hr(),
      span(
        class = "modal-content-label",
        "Submit as part of team? Please join a team that has registered the challenge"),
      span(
        class = "modal-content-text",
        "You are submitting as individual"),
      actionButton("indi-confirm", "Confirm", class = "next-btn")
    ),
    title = NULL,
    footer = NULL,
    size = "m",
    easyClose = TRUE,
    fade = TRUE
  )
}

# TODO: currently ID is hard code, change it to a module
submit_confirm_dialog <- function(teams=NULL) {
  
  has_team <- length(teams) > 0
  choices <- "I am submitting as an individual"
  
  if (has_team) choices <- c(choices, "I am submitting as part of a team")

  modalDialog(
    tags$div(
      id = "submit-dialog",
      class = "flex flex-column",
      div(
        class = "flex",
        h4("Who is submitter?"),
        actionButton("submit-close-btn", "x", class = "close-button")
      ),
      hr(),
      uiOutput("submit-option-error", class = "error"),
      radioButtons("submit-options", label = NULL,
                   choices = choices, selected = character(0)),
      
      if (has_team) {
        tagList(
          selectInput(
            inputId = "team-options",
            label = "Select team",
            choices = teams
          )
          # tags$a("Register a different team", href = "google.com", target = "_blank")
        )
      },
      div(
        class = "flex flex-column flex-center",
        actionButton("submit-confirm-btn", "Confirm", class = "next-btn"),
        span(id = "submit-loading-text", class = "dark-grey", "submitting ... please wait")
      )
    ),
    title = NULL,
    footer = NULL,
    size = "m",
    easyClose = FALSE,
    fade = TRUE
  )
}
