
#' Get live events
#'
#' Get information about live events currently going on..
#'
#' @param save_details logical. Should just a table be returned, or also details about the requests.
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return Returns an object of class `Schedule` if details were saved. Otherwise, a `data.frame`
#'         of scheduled matches for the queried league.
#' @export
getLive <- function(
  save_details = FALSE,
  hl = "en-US"
) {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getLive")

  query_result <- query_api(
    url = url,
    key = key,
    hl = hl
  )


  parsed <- query_result$parsed
  events <- parsed$data$schedule$events
  # TODO Null check
  if(length(events) == 0) stop("There are no live events taking place right now.")

  # alternative way of doing this, utilizing tidyr
  event_info <- events[,1:5]
  names(event_info)[which(names(event_info) == "id")] <- "event_id"

  league_info <- purrr::pluck(events, "league")
  names(league_info)[which(names(league_info) == "id")] <- "league_id"

  match_data <- purrr::pluck(events, "match")
  match_strat_info <- purrr::pluck(match_data, "strategy")

  matches <- match_data[, which(names(match_data) != "strategy")]
  match_teams_info <- tidyr::unnest_wider(matches, teams, names_sep = "_") %>%
    tidyr::unnest_wider(teams_name, names_sep = "_") %>%
    tidyr::unnest_wider(teams_slug, names_sep = "_") %>%
    tidyr::unnest_wider(teams_code, names_sep = "_") %>%
    tidyr::unnest_wider(teams_image, names_sep = "_") %>%
    tidyr::unnest_wider(teams_result, names_sep = "_") %>%
    tidyr::unnest_wider(teams_record, names_sep = "_") %>%
    tidyr::unnest_wider(teams_result_outcome, names_sep = "_") %>%
    tidyr::unnest_wider(teams_result_gameWins, names_sep = "_") %>%
    tidyr::unnest_wider(teams_record_wins, names_sep = "_") %>%
    tidyr::unnest_wider(teams_record_losses, names_sep = "_")

  names(match_teams_info)[which(names(match_teams_info) == "id")] <- "match_id"

  final_df <- cbind(
    event_info, league_info, match_strat_info, match_teams_info
  )

  names(final_df)[stringr::str_detect(names(final_df), "teams_")] <-
    names(final_df)[stringr::str_detect(names(final_df), "teams_")] %>%
    stringr::str_remove("teams_") %>%
    stringr::str_replace("_1", "_team_1") %>%
    stringr::str_replace("_2", "_team_2")


  return_obj <- structure(
    list(
      live_events = final_df,
      hl = hl,
      response = query_result$response
    ),
    class = "live"
  )

  if(save_details) {
    return(return_obj)
  } else {
    return(final_df)
  }

}

parse_live_events <- function(query_result) {
  events <- query_result$parsed$data$schedule$events
  events_m <- events[, c("startTime", "id", "state", "type", "blockName")]
  events_m[, c("league.name",
               "league.slug",
               "league.id",
               "league.image",
               "league.priority")] <- events$league[, c("name", "slug", "id", "image", "priority")]
  events_m$match.id <- events$match$id
  events_m$match.strategy.type <- events$match$strategy$type
  events_m$match.strategy.count <- events$match$strategy$count

  # TODO
  # adapt create_schedule_df to the values of getLive
  # difference is that the schedule events do not have team slugs


}
