# set_apikey()
key <- get_apikey()
# hl = "en-US"
gameId <- "104169295283008519"

startingTime <- "2020-06-12 16:28:00"

test_that("get_window basic works.",
          expect_length(get_window(gameId), 4))

test_that("startingTime gets parsed",
  expect_length(get_window(gameId, startingTime = startingTime), 4))

details <- get_window(gameId, save_details = TRUE)
