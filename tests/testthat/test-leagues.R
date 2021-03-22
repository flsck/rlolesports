# set_apikey()

# leagues tests -------
leagues <- getLeagues(save_details = TRUE)

test_that(
  "LCS and LEC can be found",
  expect_s3_class(leagues, "leagueRequest")
)

# Tournament tests ----
lec_id <- "98767991302996019"
tourney <- getTournamentsForLeague(leagueId = lec_id)

test_that(
  "Tournaments have the relevant names",
  expect_equal(
    names(tourney),
    c("id", "slug", "startDate", "endDate")
  )
)
