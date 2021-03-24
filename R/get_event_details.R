#' get_event_details
#'
#' Get details for a given match ID. This is useful to get the
#' `gameId`s of single games for a given match. So one match can
#' have different `gameId`s, which can be found by `value$games$game_id`
#' where `value` is the response value of this function with the `save_details`
#' flag set to false.
#' These `gameId`s can be used for further analysis in the functions `get_window()`
#' and `get_details()`.
#'
#' @param matchId the id of the match of interest.
#' @inheritParams get_standings
#' @return data.frame of event details or raw query.
#'
#' @export
get_event_details <- function(matchId,
                            hl = "en-US",
                            save_details = FALSE) {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getEventDetails")

  query_result <- query_api(
    url = url,
    key = key,
    id = matchId,
    hl = hl
  )
  # Status code catcher
  if(query_result$status_code != 200) {
    message(paste0("Something went wrong, status code: "), query_result$status_code)
    return(query_result)
  }
  # Catch if raw objects is returned
  if(save_details == TRUE) {
    return(query_result)
  }
  if(is.null(query_result$parsed$data$event)) {
    message("Events seem to be empty.")
    return(query_result)
  }

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
