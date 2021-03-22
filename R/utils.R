#' Set an Environment Variable for the public Esports API key
#'
#' `set_apikey` creates an environmental variable for the League of Legend Esports API Key,
#' to be used by other functions calling the API and requiring authentification.
#' @export
set_apikey <- function() {
  tryCatch(
    {
      message("Setting LOL Esports API Key ...")
      Sys.setenv(LOLESPORTS_KEY = "0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z")
      message("Done")
    },
    error = function(cond) {
      message(paste("Setting Environment Variable caused an error"))
      message("Error message:")
      message(cond)
    }
  )
  }

#' Check if the Environment Variable for the Esports API is set
#'
#' `check_apikey` informs the user whether the LoL Esports API Key is available as an environmental variable.
#' @export
check_apikey  <- function() {
  key <- Sys.getenv("LOLESPORTS_KEY")
  if(identical(key, "")) {
    stop("Env var is not set. Please set the env var LOLESPORTS_KEY via 'set_key()' function",
         call. = FALSE)
  }

  print("League ESports API Key is loaded")
}

#' get the api key for processing by other functions
get_apikey <- function() {
  # key <- Sys.getenv("LOLESPORTS_KEY")
  # if(identical(key, "")) {
  #   stop("Env var is not set. Please set the env var LOLESPORTS_KEY via 'set_key()' function",
  #        call. = FALSE)
  # }
  key <- "0TvQnueqKa5mxJntVWt0w4LpLfEkrV1Ta8rQBb9Z"
  return(key)
}

#' Return the base league API URL
#'
league_url <- function() {
  url <- "https://esports-api.lolesports.com/persisted/gw/"
  return(url)
}

#' check locale
valid_locales <- function(){
  valid_codes <- c("en-US", "en-GB", "en-AU", "cs-CZ", "de-DE", "el-GR", "es-ES",
                   "es-MX", "fr-FR", "hu-HU", "it-IT", "pl-PL", "pt-BR", "ro-RO",
                   "ru-RU", "tr-TR", "ja-JP", "ko-KR")

  return(valid_codes)
}


#' Query function
#'
#' Builds a GET Query for the LOL Esports API and returns
#' a list with response, status code and parsed data
#'
#' @param url the url that needs to be queries
#' @param key api key
#' @param ... Possible query parameters
query_api <- function(url, key, ...) {
  # GET request
  response <- httr::GET(
    url = url,
    query = list(...),
    httr::add_headers("x-api-key" = key)
  )
  # check status code
  status_code <- httr::status_code(response)
  # parse request
  parsed <- jsonlite::fromJSON(
    httr::content(response, "text", encoding = "UTF-8"),
    simplifyDataFrame = TRUE
  )

  return_obj <- list(
    response = response,
    status_code = status_code,
    parsed = parsed
  )

  return(return_obj)
}

# gratefully taken from https://github.com/ropensci/rnassqs/commit/e36b38d4f43080fbf3e53abe49502eeebade6402
#stck <- stack(list(hl = hl, id = c("tsm", "cloud9")))
#params <- as.list(setNames(res$values, res$ind))

expand_list <- function(list_obj) {
  stacked <- utils::stack(list_obj)
  as.list(stats::setNames(stacked$values, stacked$id))
}



