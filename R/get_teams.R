#' Get information about a team and its roster
#'
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#' @param team_slug string. The team id or slug name.
#' @param save_details logical. Should a detailed object with the appropriate response
#'                     values of the query be returned or just the relevant tables of
#'                     that response
#'
#' @return If save_detals is `TRUE`, an object of class `teams` with details of the query.
#'         Otherwise, a list of two tables, one for the team data, one for the player data
#'         of that team.
#'
#' @export
get_teams <- function(
  team_slug,
  save_details = FALSE,
  hl = "en-US"
) {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")

  key <- get_apikey()
  url <- paste0(league_url(), "getTeams")

  query_result <- query_api(
    url = url,
    key = key,
    hl = hl,
    id = team_slug
  )
  # Status code catcher
  if(query_result$status_code != 200) {
    message(paste0("Something went wrong, status code: "), query_result$status_code)
    return(query_result)
  }

  teams <- query_result$parsed$data$teams

  team_df <- as.data.frame(teams[, 1:8])
  colnames(team_df)[1] <- "team_id"
  player_df <- as.data.frame(teams$players[[1]])
  player_df$team <- team_df$name[1]

  tables <- list(
    team = team_df,
    players = player_df
  )

  return_obj <- structure(
    list(
      team = team_df,
      players = player_df,
      hl = hl,
      team_id = team_slug,
      response = query_result$response
    ),
    class = "teams"
  )

  if(save_details) {
    return(return_obj)
  } else {
    return(tables)
  }
}
