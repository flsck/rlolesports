set_apikey()
key <- get_apikey()
# hl = "en-US"
gameId <- "104169295283008519"

startingTime <- "2020-06-12 16:28:00"

test_that("getWindow basic works.",
          expect_length(getWindow(gameId), 4))

test_that("startingTime gets parsed",
  expect_length(getWindow(gameId, startingTime = startingTime), 4))

details <- getWindow(gameId, save_details = TRUE)
