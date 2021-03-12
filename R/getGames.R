#' Get games data for series games
#'
#' If a game is a best-of series, the function can return the specific game IDs
#' of the series.
#'
#' @param gameId string. The ID of the game for which data should be searched.
#' @param save_details logical. Shoudl details be saved?
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return A data.frame of games data or the raw query.
#'
#' @export
getGames <- function(gameId,
                     hl = "en-US",
                     save_details = FALSE) {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getGames")

  query_result <- query_api(
    url = url,
    key = key,
    id = gameId,
    hl = hl
  )
  # Status code catcher
  if(query_result$status_code != 200) {
    message(paste0("Something went wrong, status code: "), query_result$status_code)
    return(query_result)
  }
  # Catch if raw objects is returned
  if(save_details == TRUE) {
    return(query_result)
  }


  parsed <- query_result$parsed
  g <- parsed$data$games %>% tidyr::unnest_wider("vods", names_sep = "_")
  return(g)
}
