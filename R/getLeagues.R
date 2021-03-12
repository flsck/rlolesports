#' Get information about a league, the standings and its various tournaments.
#'
#' The function is used to get detailed information about specific leagues.
#' The data.frame contained in the returned list gives information about
#' a leagues region, id, icon and more.
#'
#' @param save_details logical. Should a detailed list, including the API
#'                     response be returned, or just a data.frame?
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return A list containing a data.frame witht the information about the leagues,
#'         the used language code and the response to the original GET request
#'         contained in the function.
#' @export
getLeagues <- function(save_details = FALSE,
                       hl = "en-US") {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")

  key <- get_apikey()
  url <- paste0(league_url(), "getLeagues")

  # # GET request
  # resp <- httr::GET(
  #   url = url,
  #   query = list(hl = hl),
  #   httr::add_headers("x-api-key" = key)
  # )
  # # parse request
  # parsed <- jsonlite::fromJSON(
  #   httr::content(resp, "text", encoding = "UTF-8"),
  #   simplifyDataFrame = TRUE
  # )

  query_result <- query_api(
    url = url,
    key = key,
    hl = hl
  )
  # Status code catcher
  if(query_result$status_code != 200) {
    message(paste0("Something went wrong, status code: "), query_result$status_code)
    return(query_result)
  }

  table <-  as.data.frame(query_result$parsed[[1]][[1]])

  # return parsed request as own s3 object
  return_obj <- structure(
    list(
      content = query_result$parsed[[1]][[1]],
      hl = hl,
      response = query_result$response
    ),
    class = "leagueRequest"
  )

  if(save_details) {
    return(return_obj)
  } else {
    return(table)
  }
}
