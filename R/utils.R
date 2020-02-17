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
  key <- Sys.getenv("LOLESPORTS_KEY")
  if(identical(key, "")) {
    stop("Env var is not set. Please set the env var LOLESPORTS_KEY via 'set_key()' function",
         call. = FALSE)
  }
  return(key)
}



