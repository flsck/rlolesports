
# Print Methods etc -----

print.leagueRequest <- function(x, ...) {
  cat("getLeagues with hl: ", x$hl, "\n", sep = "")
  utils::str(x$content, vec.len = 1) # print(head(x$content))
  print(x$response)
  invisible(x)
}

print.tournamentsRequest <- function(x, ...) {
  cat("Tournaments for Id: ", x$leagueId, "\n", sep = "")
  utils::str(x$content, vec.len = 1)
  print(x$response)
  invisible(x)
}


