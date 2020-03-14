#' Get Information about current Schedules
#'
#' @param leagueId string. The league id to be queried.
#' @param save_details logical. Shoudl details be saved?
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#' @param pageToken Base 64 encoded string used to detemin the next "page" of data to pull,
#'
#' @return Returns something
#' @export
getSchedule <- function(
  leagueId,
  pageToken,
  save_details = FALSE,
  hl = "en-U"
) {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getSchedule")

  query_result <- query_api(
    url = url,
    key = key,
    hl = hl,
    leagueId = leagueId
  )
  # TODO Check in the query result if there are more tables to query...

  events <- query_result$parsed$data$schedule$events
  # TODO parse the events data into a coherent table
  events_2 <- events[, 1:5]
  events_2$match.id <- events$match$id
  events_2$match.flags <- unlist(events$match$flags)
  events_2$match.strategy.type <- events$match$strategy$type
  events_2$match.strategy.count <- events$match$strategy$count
  sched_df <- create_schedule_df(events$match$teams)
  events_final_p1 <- cbind(events_2, sched_df)
  # TODO to do the above, check if get Standings Code can be reused here
  if(query_result$parsed$data$schedule$pages$older)



  if(save_details){
    # return s3 object
  } else {
    # return an easy view of the tables
  }
}


create_schedule_df <- function(list_of_teams) {
  result <- as.data.frame(
    do.call(
      rbind,
      (
        lapply(
          list_of_teams,
          function(x) {
            colnames(x)[1:3] <- paste0(colnames(x)[1:3], "_team")
            data <- as.data.frame(t(unlist(x)))
            colnames(data)[c(7, 9, 11, 13)] <- gsub("1", "_team1", colnames(data)[c(7, 9, 11, 13)])
            colnames(data)[c(8, 10, 12, 14)] <- gsub("2", "_team2", colnames(data)[c(8, 10, 12, 14)])

            data
          }
        )
      )
    )
  )
  return(result)
}
