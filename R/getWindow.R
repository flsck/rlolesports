startingTime <- "2020-06-12 16:28:00" # dekete me

#' getWindow
#'
#' @inheritParams getGames
getWindow <- function(gameId,
                      hl = "en-US",
                      startingTime = NULL,
                      save_details = FALSE) {
  hl = "en-US" # delete me
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

  meta_data <- query_result$parsed$gameMetadata
  team_data <- rbind(meta_data$blueTeamMetadata$participantMetadata,
                     meta_data$redTeamMetadata$participantMetadata)

  # separate blue and red to ease some of the workings
  blue_team <- query_result$parsed$frames$blueTeam
  blue_team$timestamp <- query_result$parsed$frames$rfc460Timestamp
  row.names(blue_team) <- NULL

  red_team <- query_result$parsed$frames$redTeam
  red_team$timestamp <- query_result$parsed$frames$rfc460Timestamp
  row.names(red_team) <- NULL

  blue_team_long <- blue_team %>%
    tidyr::unnest_longer("participants", names_repair = "unique")
  blue_team_members <- cbind(
    data.frame(timestamp = blue_team_long$timestamp),
    blue_team_long %>% dplyr::pull("participants") %>% dplyr::rename(participantGold = totalGold)
    )

  red_team_members <- red_team %>%
    tidyr::unnest_longer("participants", names_repair = "unique") %>%
    dplyr::pull("participants") %>%
    dplyr::rename(participantGold = totalGold)

  blue_team <- cbind(
    blue_team[, c("timestamp", "totalGold", "inhibitors", "towers", "barons", "totalKills", "dragons")],
    blue_team_members
  )
  red_team <- cbind(
    red_team[, c("timestamp", "totalGold", "inhibitors", "towers", "barons", "totalKills", "dragons")],
    red_team_members
  )

  both_teams <- rbind(blue_team, red_team)
  both_teams <- dplyr::left_join(both_teams, team_data, by = c("participantId" = "participantId"))

  return()

}
