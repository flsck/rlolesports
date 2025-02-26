% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_complete_details.R
\name{get_complete_details}
\alias{get_complete_details}
\title{Get the return of get_details for a whole game}
\usage{
get_complete_details(gameId, hl = "en-US")
}
\arguments{
\item{gameId}{string. The ID of the game for which data should be searched.}

\item{hl}{string. Locale or language code using ISO 639-1 and ISO 3166-1 alpha-2.}
}
\value{
A list of a game data.frame and associated meta data.
}
\description{
This function automatically scans the initial return of
`get_window()` for a given gameId for relevant timestamps,
which are utilized in another query to function, giving
another timestamp. This continues until no new data can be
generated by the query, indicating that a game is over.
}
