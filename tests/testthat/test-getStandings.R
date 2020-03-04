set_apikey()
lcs_id <- "103462439438682788"
lec_id <- "103462459318635408"
# test match_processing ------

key <- get_apikey()
url <- paste0(league_url(), "getStandings")
hl  <-  "en-US"

## LCS ------------
query_result <- query_api(
  url = url,
  key = key,
  tournamentId = lcs_id,
  hl = hl
)
match_list_lcs <- process_matches(query_result$parsed)

test_that(
  "NA LCS 2020 has a Regular Season and Playoffs",
  expect_equal(names(match_list_lcs), c("Regular Season", "Playoffs"))
)

## LEC -----------
query_result <- query_api(
  url = url,
  key = key,
  tournamentId = lec_id,
  hl = hl
)
match_list_lec <- process_matches(query_result$parsed)
test_that(
  "EU LEC 2020 has a Regular Season and Playoffs",
  expect_equal(names(match_list_lec), c("Regular Season", "Playoffs"))
)

## Compare LCS and LEC-----
test_that(
  "EU and NA have the same structure in Regular Season",
  expect_equal(
    names(match_list_lcs$`Regular Season`),
    names(match_list_lec$`Regular Season`)
  )
)

test_that(
  "EU and NA have the same structure in Regular Season",
  expect_equal(
    names(match_list_lcs$Playoffs),
    names(match_list_lec$Playoffs)
  )
)






