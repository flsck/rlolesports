# Setup -------
key <- get_apikey()
url <- paste0(league_url(), "get_teams")
hl <-  "en-US"

# single example -----
team_slug <- "cloud9"

query_result <- query_api(
  url = url,
  key = key,
  hl = hl,
  id = team_slug
)

test_that(
  "teams query returns status code 200",
  expect_equal(query_result$status_code, 200)
)

compl_return <- get_teams(team_slug = team_slug,
                         save_details = TRUE)

test_that(
  "complete function returns status code 200",
  expect_equal(
    compl_return$response$status_code, 200
  )
)
