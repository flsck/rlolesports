set_apikey()

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

