#'
#'
#' TODO: late prio

getGames <- function(gameId,
                     save_details = FALSE,
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
}

gameId <- "104174613333860709"
