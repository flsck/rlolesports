

#' Get a list of completed events
#'
#' This function takes a tournament Id and returns completed events
#'
#' @param tournamentId string. Can be taken from the getLeagues() function.
#' @param save_details logical. Should just a table be returned, or also details about the requests.
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return Returns something
#' @export
getCompletedEvents <- function(tournamentId,
                               save_details = FALSE,
                               hl = "en-US") {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getCompletedEvents")

  query_result <- query_api(
    url = url,
    key = key,
    tournamentId = tournamentId,
    hl = hl
  )
  # Status code catcher
  if(query_result$status_code != 200) {
    message(paste0("Something went wrong, status code: "), query_result$status_code)
    return(query_result)
  }

  events <- query_result$parsed$data$schedule$events
  # removing vods for now..
  events$games <- NULL

  # parse team data from events frame
  team_df <- parse_event_teams(events)
  events$match <- NULL

  parsed_events <- cbind(events, team_df)

  return_obj <- structure(
    list(
      events = parsed_events,
      hl = hl,
      tournamentId = tournamentId,
      response = query_result$response
    ),
    class = "completedevents"
  )

  if (!save_details & query_result$status_code == 200) {
    return(parsed_events)
  } else if(save_details & query_result$status_code != 200) {
    message(paste0("Status code ", query_result$status_code, " returned."))
    return(return_obj)
  } else {
    return(return_obj)
  }
}



parse_event_teams <- function(events) {
  team_df <- as.data.frame(
    do.call(
      rbind,
      (
        lapply(
          events$match$teams,
          function(x) {
            team_meta <- x
            colnames(team_meta)[1:3] <- c("name_team", "code_team", "image_team")
            team_data <- as.data.frame(t(unlist(team_meta)))
            team_data
          }
        )
      )
    )
  )

  return(team_df)
}
