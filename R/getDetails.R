#' Get game data from a certain starting time
#'
#' The function returns player data in a specified timeframe. It is possible
#' to set a certain starting point for the timeframe, but final length is not
#' able to be predetermined.
#'
#' @param gameId string. The ID of the game for which data should be searched.
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#' @param startingTime a string in the form `Y-m-d H:M:S`. Needs to be compatible with
#' `lubridate::ymd_hms()`.
#' @param save_details logical. Should details be saved?
#'
#'
#' @return A list of game metadata and a data.frame of game data, or raw query result.
#' In the case of a data.frame, participantID 1 to 5 is blue team, 6 to 10 is red team.
#'
#' @export
getDetails <- function(gameId,
                       hl = "en-US",
                       startingTime = NULL,
                       save_details = FALSE) {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0("https://feed.lolesports.com/livestats/v1/details/", gameId)
  if(is.null(startingTime)) {
    query_result <- query_api(
      url = url,
      key = key,
      hl = hl
    )
  } else { # this just works with timestamp values from the query returns. pretty cool
    st_org <- lubridate::ymd_hms(startingTime)
    processed_time <- strftime(st_org, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

    query_result <- query_api(
      url = url,
      key = key,
      hl = hl,
      startingTime = processed_time
    )
  }
  # Status code catcher
  if(query_result$status_code != 200) {
    message(paste0("Something went wrong, status code: "), query_result$status_code)
    return(query_result)
  }
  # Catch if raw objects is returned
  if(save_details == TRUE) {
    return(query_result)
  }

  timestamp <- query_result$parsed$frames$rfc460Timestamp
  participants <- query_result$parsed$frames$participants
  n_p <- nrow(participants[[1]])
  timecol <- rep(timestamp, each = n_p)

  one_df <- dplyr::bind_rows(participants) # i choose violence, because this can ignore
                                           # rownames(), but every one of my attempts to
                                           # do so was thwarted by invisible magic.
  one_df$timestamp <- timecol
  one_df <- one_df[, c(ncol(one_df), 1:(ncol(one_df)-1))]

  return(one_df)
}
