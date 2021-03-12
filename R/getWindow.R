#' Get game data from a certain starting time
#'
#' The function returns player data in a specified timeframe. It is possible
#' to set a certain starting point for the timeframe, but final length is not
#' able to be predetermined.
#'
#' @param gameId string. The ID of the game for which data should be searched.
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#' @param startingTime a string in the form `Y-m-d H:M:S`. Needs to be compatible with
#' `lubridate::ymd_hms()`.
#' @param save_details logical. Should details be saved?
#'
#'
#' @return A list of game metadata and a data.frame of game data, or raw query result.
#'
#' @export
getWindow <- function(gameId,
                      hl = "en-US",
                      startingTime = NULL,
                      save_details = FALSE) {
  # Test if this gets around obnoxious note
  timestamp <- totalGold <- NULL # delete this in case of shenanigans
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0("https://feed.lolesports.com/livestats/v1/window/", gameId)


  if(is.null(startingTime)) {
    query_result <- query_api(
      url = url,
      key = key,
      hl = hl
    )
  } else {
    st_org <- lubridate::ymd_hms(startingTime)
    processed_time <- strftime(st_org , "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

    query_result <- query_api(
      url = url,
      key = key,
      hl = hl,
      startingTime = processed_time
    )
  }
  # Status code catcher
  if(query_result$status_code != 200) {
    message(paste0("Something went wrong, status code: "), query_result$status_code)
    return(query_result)
  }
  # Catch if raw objects is returned
  if(save_details == TRUE) {
    return(query_result)
  }

  meta_data <- query_result$parsed$gameMetadata
  team_data <- rbind(meta_data$blueTeamMetadata$participantMetadata,
                     meta_data$redTeamMetadata$participantMetadata)

  # separate blue and red to ease some of the workings
  blue_team <- query_result$parsed$frames$blueTeam
  blue_team$timestamp <- query_result$parsed$frames$rfc460Timestamp
  row.names(blue_team) <- NULL
  blue_team <- dplyr::distinct(blue_team, timestamp, .keep_all = TRUE)

  red_team <- query_result$parsed$frames$redTeam
  red_team$timestamp <- query_result$parsed$frames$rfc460Timestamp
  row.names(red_team) <- NULL
  red_team <- dplyr::distinct(red_team, timestamp, .keep_all = TRUE)

  # Aggregate Blue Data
  blue_team_long <- blue_team %>%
    tidyr::unnest_longer("participants", names_repair = "unique")
  blue_team_members <- cbind(
    data.frame(timestamp = blue_team_long$timestamp),
    blue_team_long %>% dplyr::pull("participants") %>% dplyr::rename(participantGold = totalGold)
  )
  blue_team_joined <- dplyr::right_join(blue_team, blue_team_members, by = "timestamp")
  blue_team_joined$team <- "blue"

  # Aggregate Red Data
  red_team_long <- red_team %>%
    tidyr::unnest_longer("participants", names_repair = "unique")
  red_team_members <-  cbind(
    data.frame(timestamp = red_team_long$timestamp),
    red_team_long %>% dplyr::pull("participants") %>% dplyr::rename(participantGold = totalGold)
  )
  red_team_joined <- dplyr::right_join(red_team, red_team_members, by = "timestamp")
  red_team_joined$team <- "red"

  both_teams <- rbind(blue_team_joined, red_team_joined)
  both_teams <- dplyr::left_join(both_teams, team_data, by = c("participantId" = "participantId"))

  return(list(window = both_teams,
              metaData = meta_data))

}
