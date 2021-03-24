# set_apikey()

# leagues tests -------
leagues <- get_leagues(save_details = TRUE)

test_that(
  "LCS and LEC can be found",
  expect_s3_class(leagues, "leagueRequest")
)

# Tournament tests ----
lec_id <- "98767991302996019"
tourney <- get_tournaments_for_league(leagueId = lec_id)

test_that(
  "Tournaments have the relevant names",
  expect_equal(
    names(tourney),
    c("id", "slug", "startDate", "endDate")
  )
)
