#' getGames
#'
#' @param gameId The id of the game of interest
#' @inheritParams getSchedule
getGames <- function(gameId,
                     hl = "en-US") {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getGames")

  query_result <- query_api(
    url = url,
    key = key,
    id = gameId,
    hl = hl
  )

  parsed <- query_result$parsed
  g <- parsed$data$games %>% tidyr::unnest_wider("vods", names_sep = "_")
  return(g)
}
