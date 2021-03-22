# set_apikey()
key <- get_apikey()

gameId <- "104169295283008519"

startingTime <- "2020-06-12 16:28:00"


test_that("getDetails works with a starting time",
          expect_silent(getDetails(gameId, startingTime = startingTime, save_details = TRUE)))

test_that("getDetails works w/o starting time",
          expect_silent(getDetails(gameId, save_details = TRUE)))

