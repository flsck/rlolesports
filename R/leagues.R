#' Returns the base league api url
league_url <- function() {
  url <- "https://esports-api.lolesports.com/persisted/gw/"
  return(url)
}

getLeagues <- function(hl = "en-US") {
  key <- get_apikey()
  url <- paste0(league_url(), "getLeagues")

  resp <- httr::GET(
    url = url,
    query = list(hl = hl),
    httr::add_headers("x-api-key" = key)
  )

  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyDataFrame = TRUE
  )


  structure(
    list(
      content = parsed[[1]][[1]],
      hl = hl,
      response = resp
    ),
    class = "leagueRequest"
  )

}

print.leagueRequest <- function(x, ...) {
  cat("getLeagues for hl: ", x$hl, "\n", sep = "")
  str(x$content, vec.len = 1)
  invisible(x)
}


