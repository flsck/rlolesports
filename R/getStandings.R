# getStandings ----------

#' Query the standings of a specified tournament
#'
#' The function takes a tournamend ID as argument and returns either a data.frame of the current standings
#' for the selected tournament, or a list including the data.frame as an element, plus the raw API response.
#'
#' @param tournamentId string. Can be taken from the getLeagues() function.
#' @param save_details logical. Should just a table be returned, or also details about the requests.
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return Returns something
#' @export
getStandings <- function(tournamentId,
                         save_details = FALSE,
                         hl = "en-US") {

  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getStandings")

  query_result <- query_api(
    url = url,
    key = key,
    tournamentId = tournamentId,
    hl = hl
  )

  match_list <-  process_matches(query_result$parsed)
  # TODO Parse Standings, create a function for that

  return_obj <- structure(
    list(
      match_list = match_list,
      # Append Standings once implemented
      hl = hl,
      tournamentId = tournamentId,
      response = query_result$response
    ),
    class = "standings"
  )

  if (!save_details & query_result$status_code == 200) {
    return(table)
  } else if(save_details & query_result$status_code != 200) {
    message(paste0("Status code ", query_result$status_code, " returned."))
    return(return_obj)
  } else {
    return(return_obj)
  }
}



#' Processes matches
#'
#' processes the parsed standings data
#' @param parsed parsed data from a get request
process_matches <- function(parsed) {
  stages <- parsed$data$standings$stages[[1]]

  round_data <- list()
  for(i in 1:nrow(stages)) {
    list_of_matches <- ((stages[[4]][[i]])[[2]][[1]])[[5]]

    match_df <- create_match_df(list_of_matches)

    match_df_combined <- cbind(((stages[[4]][[i]])[[2]][[1]])[1:4], match_df)
    names(match_df_combined)[1] <- "match_id"
    match_df_combined$flags <- as.character(match_df_combined$flags)
    match_df_combined$flags <- ifelse(match_df_combined$flags == "character(0)",
                                      NA,
                                      match_df_combined$flags)

    match_df_combined$round_name <- (stages[[4]][[i]])[[1]]
    round_data[[i]] <- match_df_combined
  }
  names(round_data) <-stages$name
  # TODO: Figure out a way to get the result column of every possible round (playoff, nonplayoff)
  #       to be the same shape ..
  # all_matches <- as.data.frame(
  #   do.call(
  #     rbind, lapply(match_data, function(x) x)
  #   )
  # )

  return(round_data)

}



#' create match dataframe object
#'
#' Unpacks the list of teams in a match list into a single row data frame
#' @param list_of_matches list of all the matches from a given tournament
create_match_df <- function(list_of_matches) {
  result <- as.data.frame(
    do.call(
      rbind,
      (
        lapply(
          list_of_matches,
          function(x) {
            match_meta <- x
            colnames(match_meta)[1:5] <- c("team_id", "slug_", "name_", "code_", "image_")
            match_data <- as.data.frame(t(unlist(match_meta)))
            match_data
          }
        )
      )
    )
  )
  return(result)
}






