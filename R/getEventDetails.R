
#' getEventDetails
#'
#'
#'
#' @param matchId the id of the match of interest.
#' @inheritParams getStandings
getEventDetails <- function(matchId,
                            hl = "en-US") {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getEventDetails")

  query_result <- query_api(
    url = url,
    key = key,
    id = matchId,
    hl = hl
  )

  event <- query_result$parsed$data$event
  # start stuff
  details <- data.frame(
    matchid = event$id,
    eventtype = event$type,
    tournament_id = event$tournament$id
  )
  # league
  league <- as.data.frame(event$league)
  colnames(league) <- paste0("league_", colnames(league))

  # match
  teams <- event$match$teams[,1:4]
  games <- event$match$games %>%
    tidyr::unnest_wider("teams", names_sep = "_") %>%
    tidyr::unnest_wider("teams_id", names_sep = "_") %>%
    tidyr::unnest_wider("teams_side", names_sep = "_")
  colnames(games)[colnames(games) == "id"] <-  "game_id"

  l <- list(league = league,
            games = games,
            teams = teams)

  return(l)

}
