#' Get Information about current Schedules
#'
#' @param leagueId string. The league id to be queried.
#' @param check_old_pages logical. SHould older pages be querried as well?
#' @param pageToken Base 64 encoded string used to determine the next "page" of data to pull.
#'                  Only used if `check_old_pages` is `TRUE`.
#' @param save_details logical. Shoudl details be saved?
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return Returns an object of class `Schedule` if details were saved. Otherwise, a `data.frame`
#'         of scheduled matches for the queried league.
#' @export
getSchedule <- function(
  leagueId,
  check_old_pages = TRUE,
  pageToken = NULL,
  save_details = FALSE,
  hl = "en-US"
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
  events_list <- list()
  events_list[[1]] <- parse_schedule_events(query_result)

  if(check_old_pages) {
    if(is.null(pageToken)) {
      older_page <- query_result$parsed$data$schedule$pages$older
    } else {
      older_page <- pageToken
    }
    while(!is.null(older_page)) {
      cat("Getting page ", length(events_list) + 1, "\n")
      query_result_older <- query_api(
        url = url,
        key = key,
        hl = hl,
        leagueId = leagueId,
        pageToken = older_page
      )
      events_list[[length(events_list) + 1]] <- parse_schedule_events(query_result_older)
      older_page <- query_result_older$parsed$data$schedule$pages$older
    }

  }

  comp_events <- do.call(rbind, c(events_list, make.row.names = FALSE))
  df <- comp_events[order(comp_events$startTime),]

  if(save_details){
    structure(
      list(
        events = df,
        hl = hl,
        leagueId = leagueId,
        response = query_result$response
      ),
      class = "Schedule"
    )
  } else {
    df
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

parse_schedule_events <- function(query_result) {
  events <- query_result$parsed$data$schedule$events
  events_2 <- events[, 1:4]
  events_2$league.name <- events$league$name
  events_2$league.slug <- events$league$slug
  events_2$match.id <- events$match$id
  events_2$match.flags <- as.character(events$match$flags)
  events_2$match.strategy.type <- events$match$strategy$type
  events_2$match.strategy.count <- events$match$strategy$count
  sched_df <- create_schedule_df(events$match$teams)
  events_final_df <- cbind(events_2, sched_df)
  return(events_final_df)
}






