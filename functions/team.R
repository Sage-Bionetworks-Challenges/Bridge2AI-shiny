get_user_avatar <- function(syn, user_id) {
  out_file <- stringr::str_glue("{user_id}_avatar.png")
  tryCatch({
    download.file(
      stringr::str_glue("https://repo-prod.prod.sagebase.org/repo/v1/userProfile/{user_id}/image"),
      destfile = file.path("www", out_file),
      quiet = TRUE
    )
    out_file
  },
  error = function(e) NULL
  )
}

get_challenge <- function(syn, prod_syn_id) {
  syn$restGET(stringr::str_glue("/entity/{prod_syn_id}/challenge")) 
}

get_user_teams <- function(syn, user_id, challenge_id) {
  user_team_ids <- syn$restGET(stringr::str_glue("/user/{user_id}/team?limit=200")) %>%
    purrr::pluck("results") %>%
    purrr::map_chr("id")
  challenge_team_ids <- syn$restGET(stringr::str_glue("/challenge/{challenge_id}/challengeTeam")) %>%
    purrr::pluck("results") %>%
    purrr::map_chr("teamId")
  team_ids <- intersect(challenge_team_ids, user_team_ids)
  
  teams <- team_ids %>% purrr::map(~ syn$getTeam(.))
  
  return(teams)
}

get_participants <- function(syn, challenge_id) {
  syn$restGET(stringr::str_glue("/challenge/{challenge_id}/participant")) %>%
    purrr::pluck("results") 
}


has_registered <- function(syn, user_id, challenge_id) {
  
  participant_ids <- get_participants(syn, challenge_id)
  user_id %in% participant_ids
}
