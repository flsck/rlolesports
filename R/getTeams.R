#' Get information about a team and its roster
#'
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#' @param id string. The
#' @param save_details logical.
#'
#' @export
getTeams <- function(
  id,
  save_details = FALSE,
  hl = "en-US"
) {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")

  key <- get_apikey()
  url <- paste0(league_url(), "getLeagues")

}
