#

# It's not testing rn due to long time for a query.

#set_apikey()
#
# This is supposed to be an explanatory workflow.
# TODO: Remove this and move into a vignette.
leagues <- get_leagues(save_details = TRUE)
lec_id <- leagues$content %>%
  dplyr::filter(name == "LEC") %>%
  dplyr::select(id)
lec_id <- lec_id$id
tourney <- get_tournaments_for_league(leagueId = lec_id)
lec_spring_id <- tourney %>%
  dplyr::filter(slug == "lec_2021_split1") %>%
  dplyr::select(id) %>% dplyr::pull(1)
lec_standings <- get_standings(lec_spring_id)
lec_schedule <- get_schedule(lec_id)
g2_mad_id <- lec_schedule$match.id[1]
match_example <- get_event_details(g2_mad_id)
g2_mad_game <- match_example$games$game_id[1]
# same as
g2_mad_game <- "104169295283008519"

g2m <- get_complete_window(g2_mad_game)

