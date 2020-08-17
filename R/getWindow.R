
#' getWindow
#'
#' @inheritParams getGames
getWindow <- function(gameId,
                      hl = "en-US") {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0("https://feed.lolesports.com/livestats/v1/window/", gameId)

  query_result <- query_api(
    url = url,
    key = key,
    hl = hl
  )

  return(query_result)

}
