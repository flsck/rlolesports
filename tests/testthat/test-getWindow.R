set_apikey()
key <- get_apikey()
hl = "en-US"
gameId <- "103462460596524867"

a <- getWindow(gameId)
win <- a$parsed
blue <- win$frames$blueTeam
blue_df <- as.data.frame(blue[, 1:6])
