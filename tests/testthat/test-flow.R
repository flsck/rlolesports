set_apikey()

# This is supposed to be an explanatory workflow.
# TODO: Remove this and move into a vignette.

# leagues tests -------
leagues <- getLeagues(save_details = TRUE)

lec_id <- leagues$content %>%
  dplyr::filter(name == "LEC") %>%
  dplyr::select(id)

lec_id <- lec_id$id

tourney <- getTournamentsForLeague(leagueId = lec_id)

lec_spring_id <- tourney %>%
  dplyr::filter(slug == "lec_2021_split1") %>%
  dplyr::select(id) %>% dplyr::pull(1)

lec_standings <- getStandings(lec_spring_id)
lec_schedule <- getSchedule(lec_id)

g2_mad_id <- lec_schedule$match.id[1]

match_example <- getEventDetails(g2_mad_id)

g2_mad_game <- match_example$games$game_id[1]

g2_mad_window <- getWindow(g2_mad_game)
g2_mad_details <- getDetails(g2_mad_game)


start_window <- getWindow(g2_mad_game)$window %>%
  group_by(timestamp, team) %>%
  select(totalGold, totalKills, timestamp, gamestate, team) %>%
  slice_head()
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


g2m <- getDetails(g2_mad_game, startingTime = max_time_one)
