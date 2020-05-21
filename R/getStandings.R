# getStandings ----------

#' Query the standings of a specified tournament
#'
#' The function takes a tournament ID as argument and returns either a data.frame of the current standings
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
  standings <- process_standings(query_result$parsed)

  return_obj <- structure(
    list(
      match_list = match_list,
      standings = standings,
      hl = hl,
      tournamentId = tournamentId,
      response = query_result$response
    ),
    class = "standings"
  )

  if (!save_details & query_result$status_code == 200) {
    return(
      list(match_list = match_list,
           standings = standings)
    )
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
    for(j in 1:nrow(stages[[4]][[i]])) {
    list_of_matches <- ((stages[[4]][[i]])[[2]][[j]])[[5]]

    match_df <- create_match_df(list_of_matches)

    match_df_combined <- cbind(((stages[[4]][[i]])[[2]][[j]])[1:4], match_df)
    names(match_df_combined)[1] <- "match_id"
    # change the type of the flags
    match_df_combined$flags <- as.character(match_df_combined$flags)
    match_df_combined$flags <- ifelse(match_df_combined$flags == "character(0)",
                                      NA,
                                      match_df_combined$flags)


    match_df_combined$round_name <- (stages[[4]][[i]])[[1]][[j]]

    # collect in list
    indx <- length(round_data) + 1
    round_data[[indx]] <- match_df_combined
    names(round_data)[indx] <- stages$name[i]
    }
  }

  # Check if there are multiple matches for the same stage and collect them if so
  # WARNING: This could break if they do not have the same structure
  uniques <- unique(names(round_data))
  final_list <- list()
  for(i in uniques) {
    if(sum(names(round_data) == i) > 1) {
      indx <- which(names(round_data) == i)
      combs <- as.data.frame(
        do.call(
          rbind,
          lapply(round_data[indx], function(x) x)
        )
      )
      row.names(combs) <- NULL

      final_list[[length(final_list) + 1]] <- combs
      names(final_list)[length(final_list)] <- i
    } else {
      final_list[[length(final_list) + 1]] <- round_data[[i]]
      names(final_list)[length(final_list)] <- i
    }
  }


  return(final_list)
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

#' Process Standings Data
#'
#' Parses the Data about current standings in the respective league into an
#' easy to handle `data.frame`.
#'
#' @param parsed list. The parsed data from the standings GET request.
process_standings <- function(parsed) {
  stages <- parsed$data$standings$stages[[1]]

  round_data <- list()
  for(i in 1:nrow(stages)) {
    if(length((stages[[4]][[i]])[[3]][[1]]) == 0) { next }
    list_of_standings <- ((stages[[4]][[i]])[[3]][[1]])
    list_of_ranks <- list_of_standings[[2]]
    names(list_of_ranks) <- list_of_standings$ordinal

    lor <- lapply(list_of_ranks,
                    function(x, n, i) {
                      y <- x[, 1:5]
                      y[, 6] <- x[, 6][1]
                      y[, 7] <- x[, 6][2]
                      y
                    }
    )
    # TODO
    # this needs to include the ordinal rank of the respective teams.
    # Maybe with an additional lapply?
    lor_df <- do.call(
      rbind,
      lor
    )
    lor_df$rank <- as.integer(sub("\\.\\d", "", row.names(lor_df)))

    round_data[[i]] <- lor_df
    names(round_data)[i] <- stages$name[i]
  }

  return(round_data)
}




