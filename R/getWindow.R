
#' getWindow
#'
#' @inheritParams getGames
getWindow <- function(gameId,
                      hl = "en-US",
                      startingTime = NULL,
                      save_details = FALSE) {
  hl = "en-US"
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0("https://feed.lolesports.com/livestats/v1/window/", gameId)

  startingTime <- "2020-06-12T16:19:00Z"


  if(is.null(startingTime)) {
    query_result <- query_api(
      url = url,
      key = key,
      hl = hl
    )
  } else {
    query_result <- query_api(
      url = url,
      key = key,
      hl = hl,
      startingTime = startingTime
  )
  }

  query_result$parsed$frames$blueTeam %>%
    tidyr::unnest_wider("dragons", names_sep = "_") %>%
    tidyr::unnest_wider("participants", names_repair = "unique")

  return()

}
