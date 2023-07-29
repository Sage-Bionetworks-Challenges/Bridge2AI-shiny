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

