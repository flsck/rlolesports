set_apikey()
key <- get_apikey()
url <- paste0(league_url(), "getLive")
hl <- "en-US"

query_result <- query_api(
  url = url,
  key = key,
  hl = hl
)

parsed <- query_result$parsed
events <- parsed$data$schedule$events


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

