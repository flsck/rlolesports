
#' Get live events
#'
#' Get information about live events currently going on..
#'
#' @param hl string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.
#'
#' @return Returns an object of class `Schedule` if details were saved. Otherwise, a `data.frame`
#'         of scheduled matches for the queried league.
#' @export
getLive <- function(
  save_details = FALSE,
  hl = "en-US"
) {
  if(!(hl %in% valid_locales())) stop("hl is not valid.")
  key <- get_apikey()
  url <- paste0(league_url(), "getLive")

  query_result <- query_api(
    url = url,
    key = key,
    hl = hl
  )

  events_list <- list()



}

parse_live_events <- function(query_result) {
  events <- query_result$parsed$data$schedule$events
  events_m <- events[, c("startTime", "id", "state", "type", "blockName")]
  events_m[, c("league.name",
               "league.slug",
               "league.id",
               "league.image",
               "league.priority")] <- events$league[, c("name", "slug", "id", "image", "priority")]
  events_m$match.id <- events$match$id
  events_m$match.strategy.type <- events$match$strategy$type
  events_m$match.strategy.count <- events$match$strategy$count

  # TODO
  # adapt create_schedule_df to the values of getLive
  # difference is that the schedule events do not have team slugs


}
