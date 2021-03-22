# set_apikey()
key <- get_apikey()
url <- paste0(league_url(), "getSchedule")
hl <- "en-US"

lec_league_id <- "98767991302996019"

schedule_result <- getSchedule(lec_league_id, check_old_pages = FALSE)

test_that(
  "Schedule for LEC returns 24 columns",
  expect_equal(dim(schedule_result)[2], 24)
)


