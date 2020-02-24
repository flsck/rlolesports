
# getLeagues ---------

#' Get information about a league, the standings and its various tournaments.
#'
#' The function is used to get detailed information about specific leagues.
#' The data.frame contained in the returned list gives information about a a leagues region, id, icon and more.
#'
#' @param save_details logical. Should a detailed list, including the API response be returned, or just a data.frame?
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return A list containing a data.frame witht the information about the leagues, the used language code and the response to the original GET request
#'         contained in the function.
#' @export
getLeagues <- function(save_details = FALSE,
                       hl = "en-US") {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")

  key <- get_apikey()
  url <- paste0(league_url(), "getLeagues")

  # GET request
  resp <- httr::GET(
    url = url,
    query = list(hl = hl),
    httr::add_headers("x-api-key" = key)
  )
  # parse request
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyDataFrame = TRUE
  )

  table <-  as.data.frame(parsed[[1]][[1]])

  # return parsed request as own s3 object
  return_obj <- structure(
    list(
      content = parsed[[1]][[1]],
      hl = hl,
      response = resp
    ),
    class = "leagueRequest"
  )

  if(save_details) {
    return(return_obj)
  } else {
    return(table)
  }
}

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
#'
getTournamentsForLeague <- function(leagueId,
                                    save_details = FALSE,
                                    hl = "en-US") {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getTournamentsForLeague")

  # GET request
  resp <- httr::GET(
    url = url,
    query = list(
      leagueId = leagueId,
      hl = hl),
    httr::add_headers("x-api-key" = key)
  )
  #
  status_cd <- httr::status_code(resp)
  # parse request
  parsed <- jsonlite::fromJSON(
    httr::content(resp, "text", encoding = "UTF-8"),
    simplifyDataFrame = TRUE
  )

  if(is.null(parsed$data$leagues$tournaments))
  {
    message("No Tournament found.")
  } else {
    table <- as.data.frame(do.call(rbind, parsed$data$leagues$tournaments))
  }

  return_obj <- structure(
    list(
      content = table,
      hl = hl,
      leagueId = leagueId,
      response = resp
    ),
    class = "tournamentsRequest"
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


