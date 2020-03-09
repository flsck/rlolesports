
# getTournamentsForLeague ------

#' Get Tournaments for a given league.
#'
#' A detailed description of the function?
#'
#' @param leagueId string. The id of the league you want details of.
#' @param save_details logical. Should a detailed list, including the API response be returned, or just a data.frame?
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return list.
#' @export
getTournamentsForLeague <- function(leagueId,
                                    save_details = FALSE,
                                    hl = "en-US") {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getTournamentsForLeague")

  query_result <- query_api(
    url = url,
    key = key,
    leagueId = leagueId,
    hl = hl
  )

  if(is.null(query_result$parsed$data$leagues$tournaments))
  {
    message("No Tournament found.")
  } else {
    table <- as.data.frame(do.call(rbind, query_result$parsed$data$leagues$tournaments))
  }

  return_obj <- structure(
    list(
      content = table,
      hl = hl,
      leagueId = leagueId,
      response = query_result$response
    ),
    class = "tournamentsRequest"
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


