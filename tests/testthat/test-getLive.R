set_apikey()
key <- get_apikey()
url <- paste0(league_url(), "getLive")
hl <- "en-US"

query_result <- query_api(
  url = url,
  key = key,
  hl = hl
)

parsed <- query_result$parsed
events <- parsed$data$schedule$events


events <- data.frame(a = 1:10)
events[, c("b", "c")] <- data.frame(bb = 11:20, cc = 21:30)

