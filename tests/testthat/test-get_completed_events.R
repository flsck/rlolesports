# set_apikey()
key <- get_apikey()
url <- paste0(league_url(), "get_completed_events")
lec_id <- "103462459318635408"
hl  <-  "en-US"

query_result <- query_api(
  url = url,
  key = key,
  tournamentId = lec_id,
  hl = hl
)

events <- query_result$parsed$data$schedule$events

team_df <- parse_event_teams(events)

test_that("parsed teams from event list are correct data.frames",
          expect_s3_class(team_df, "data.frame"))

function_return <- get_completed_events(tournamentId = lec_id, save_details = TRUE)

test_that("function returns correct object structure",
          expect_s3_class(function_return, "completedevents"))


