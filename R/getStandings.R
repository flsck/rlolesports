# getStandings ----------

#' Query the standings of a specified tournament
#'
#' The function takes a tournamend ID as argument and returns either a data.frame of the current standings
#' for the selected tournament, or a list including the data.frame as an element, plus the raw API response.
#'
#' @param tournamendId
#' @param save_details
#' @param hl
#'
#' @value
#' @export
#'
getStandings <- function(tournamentId,
                         save_details = FALSE,
                         hl = "en-US") {

  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getStandings")

  # GET request
  resp <- httr::GET(
    url = url,
    query = list(
      tournamentId = tournamentId,
      hl = hl),
    httr::add_headers("x-api-key" = key)
  )

  # check status
  status_cd <- httr::status_code(resp)

  # parse
  parsed2 <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8")
    ,simplifyDataFrame = TRUE
  )


  # Parse Standings Data
  stage_content <- parsed$data$standings$stages[[1]]



  return_obj <- structure(
    list(
      content = table,
      hl = hl,
      leagueId = leagueId,
      response = resp
    ),
    class = "standings"
  )



  if (!save_details & status_cd == 200) {
    return(table)
  } else if(save_details & status_cd != 200) {
    message(paste0("Status code ", status_cd, " returned."))
    return(return_obj)
  } else {
    return(return_obj)
  }
}



#' process matches
#'
#' processes the parsed standings data
process_matches <- function(parsed) {
  stages <- parsed$data$standings$stages[[1]]

  round_data <- list()
  for(i in 1:nrow(stages)) {
    #stages[i, 4][[1]]$matches[[1]]

    list_of_matches <- ((stages[[4]][[i]])[[2]][[1]])[[5]]

    match_df <- create_match_df(list_of_matches)
    match_df_combined <- cbind(((stages[[4]][[i]])[[2]][[1]])[1:4], match_df)
    names(match_df_combined)[1] <- "match_id"
    match_df_combined$round_name <- (stages[[4]][[i]])[[1]]

    round_data[[i]] <- match_df_combined
  }

  # TODO: Figure out a way to get the result column of every possible round (playoff, nonplayoff)
  #       to be the same shape ..
  #
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
#' TODO Discuss if you want that tidy instead
#'
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






