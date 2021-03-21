

getCompleteWindow <- function(gameId,
                              hl = "en-US") {

  start_window <- getWindow(gameId, hl = hl)$window #%>%
    # group_by(timestamp, team) %>%
    # select(totalGold, totalKills, timestamp, gamestate, team) %>%
    # slice_head()
  curr_time <- tail(start_window$timestamp, 1) %>%
    lubridate::ymd_hms() %>%
    lubridate::round_date(unit="10s")
  last_time <- curr_time

  complete_data <- start_window

  game_still_going <- TRUE
  tictoc::tic()
  while(game_still_going) {

    curr_win <- getWindow(g2_mad_game, startingTime = curr_time)$window %>%
      group_by(timestamp, team) %>%
      select(totalGold, totalKills, timestamp, gamestate, team) %>%
      slice_head()
    curr_time <- tail(curr_win$timestamp, 1) %>%
      lubridate::ymd_hms() %>%
      lubridate::round_date(unit="10s")
    if(curr_time == last_time) {
      #stop("time rounding is not going well")
      curr_time <- curr_time + 10
    }
    last_time <- curr_time

    if(max(curr_win$timestamp) <= max(complete_data$timestamp)) {
      game_still_going <- FALSE
      break
    }
    game_still_going <- !any(curr_win$gamestate == "finished")

    complete_data <- bind_rows(complete_data, curr_win)
  }
  tictoc::toc()

  return(complete_data)
}


