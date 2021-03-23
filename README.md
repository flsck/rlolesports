
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rlolesports

<!-- badges: start -->
<!-- badges: end -->

The goal of rlolesports is to enable easy queries of the unofficial Riot
Games Esports API for League of Legends. It is very much a package in
development, not yet tested extensively.

The package offers very much opinionated data processing of the original
JSON returns of the API. Thus, every user-facing function has a variable
`save_details`, which can be set to `TRUE` to return the original and
unparsed query result. Without the flag, functions are built to return
lists or data.frames for easy processing in the `dplyr` universe.

## Installation

You can install the current version from [GitHub](https://github.com/)
with:

``` r
# install.packages("remotes")
remotes::install_github("flsck/rlolesports")
```

## Example

First, we use `getLeagues()` without any parameter to create a list of
leagues for which data can be queried.

``` r
library(rlolesports)

leagues <- getLeagues()

head(leagues[,1:4], 10)
#>                    id                  slug                name
#> 1  100695891328981122      european-masters    European Masters
#> 2  101097443346691685 turkey-academy-league                 TAL
#> 3  101382741235120470                   lla                 LLA
#> 4  104366947889790212                   pcs                 PCS
#> 5  105266074488398661             superliga           SuperLiga
#> 6  105266088231437431             ultraliga           Ultraliga
#> 7  105266091639104326           primeleague        Prime League
#> 8  105266094998946936          pg_nationals        PG Nationals
#> 9  105266098308571975                   nlc                 NLC
#> 10 105266101075764040       liga_portuguesa Liga Portuguesa LOL
#>                      region
#> 1                    EUROPE
#> 2                    TURKEY
#> 3             LATIN AMERICA
#> 4  HONG KONG, MACAU, TAIWAN
#> 5                    EUROPE
#> 6                    EUROPE
#> 7                    EUROPE
#> 8                    EUROPE
#> 9                    EUROPE
#> 10                   EUROPE
```

We’ll try to get some data for a match played in the LEC, so we’ll
filter the data.frame of leagues and find the ID of the LEC. (Of course,
there are many ways to achieve this. Below is just a `dplyr` way.)

``` r
# Extract the ID of the LEC
lec_id <- leagues %>%
  dplyr::filter(name == "LEC") %>%
  dplyr::select(id) %>% 
  purrr::pluck(1)

print(paste0("The ID of the LEC is: ", lec_id))
#> [1] "The ID of the LEC is: 98767991302996019"
```

To get a bit ahead of myself: The function
`getTournamentsForLeague(...)` returns all available splits or general
tournaments for a given league. The ids gathered by this function
however are NOT used when finding a leagues’s schedule, that the
leagueId’s job, which we already have! The query below will help us
later - because it allows us to find the starting date of a specific
split.

``` r
# Get the ID and dates for tournaments in the LEC
tourney <- getTournamentsForLeague(leagueId = lec_id)
head(tourney)
#>                   id            slug  startDate    endDate
#> 1 100205575629449176  eu_2018_summer 2018-06-15 2018-09-16
#> 2 101383793622305540 lec_2019_spring 2019-01-18 2019-04-14
#> 3 102147201778412187 lec_2019_summer 2019-06-07 2019-09-20
#> 4 103462459318635408 lec_2020_split1 2020-01-24 2020-04-27
#> 5 104169295253189561 lec-summer-2020 2020-06-11 2020-09-07
#> 6 105522958532258735 lec_2021_split1 2021-01-04 2021-04-11

# Extract the ID of the 2021 spring split of the LEC
lec_spring_id <- tourney %>%
  dplyr::filter(slug == "lec_2021_split1") %>%
  dplyr::select(id) %>% dplyr::pull(1)
```

This gives us the available schedule for all of LEC. This is not
optimal, because we now need to filter this schedule by the column
`startTime`, where we need to find a specific condition by ourselves. We
utilize the `tourney` data.frame from above to find the starting date of
the LEC 2021 spring split.

``` r
lec_schedule <- getSchedule(lec_id)
#> Getting page  2 
#> Getting page  3

# So we grab the respective date from our tournament data.frame! 
spring_starting_date <- dplyr::filter(tourney, id == lec_spring_id) %>% 
  dplyr::select(startDate) %>% 
  purrr::pluck(1) 

# ... and filter the schedule based on the matches starting times! 
lec_spring_schedule <- 
  dplyr::filter(lec_schedule, as.Date(startTime) >= spring_starting_date)

head(lec_spring_schedule)
#>              startTime     state  type blockName league.name league.slug
#> 1 2021-01-22T17:00:00Z completed match    Week 1         LEC         lec
#> 2 2021-01-22T18:00:00Z completed match    Week 1         LEC         lec
#> 3 2021-01-22T19:00:00Z completed match    Week 1         LEC         lec
#> 4 2021-01-22T20:00:00Z completed match    Week 1         LEC         lec
#> 5 2021-01-22T21:00:00Z completed match    Week 1         LEC         lec
#> 6 2021-01-23T16:00:00Z completed match    Week 1         LEC         lec
#>             match.id match.flags match.strategy.type match.strategy.count
#> 1 105522958534618096      hasVod              bestOf                    1
#> 2 105522958534552498      hasVod              bestOf                    1
#> 3 105522958534552532      hasVod              bestOf                    1
#> 4 105522958534618122      hasVod              bestOf                    1
#> 5 105522958534618106      hasVod              bestOf                    1
#> 6 105522958534552542      hasVod              bestOf                    1
#>       name_team1 name_team2 code_team1 code_team2
#> 1     G2 Esports  MAD Lions         G2        MAD
#> 2       Astralis  SK Gaming        AST         SK
#> 3          Rogue      EXCEL        RGE         XL
#> 4  Team Vitality Schalke 04        VIT        S04
#> 5 Misfits Gaming     Fnatic        MSF        FNC
#> 6     Schalke 04      EXCEL        S04         XL
#>                                                                      image_team1
#> 1                           http://static.lolesports.com/teams/G2-FullonDark.png
#> 2                          http://static.lolesports.com/teams/AST-FullonDark.png
#> 3                        http://static.lolesports.com/teams/Rogue_FullColor2.png
#> 4 http://static.lolesports.com/teams/1592591570387_VitalityVIT-01-FullonDark.png
#> 5  http://static.lolesports.com/teams/1592591419157_MisfitsMSF-01-FullonDark.png
#> 6                      http://static.lolesports.com/teams/S04_Standard_Logo1.png
#>                                                                      image_team2
#> 1 http://static.lolesports.com/teams/1592591395339_MadLionsMAD-01-FullonDark.png
#> 2                            http://static.lolesports.com/teams/SK_FullColor.png
#> 3                        http://static.lolesports.com/teams/Excel_FullColor2.png
#> 4                      http://static.lolesports.com/teams/S04_Standard_Logo1.png
#> 5   http://static.lolesports.com/teams/1592591295307_FnaticFNC-01-FullonDark.png
#> 6                        http://static.lolesports.com/teams/Excel_FullColor2.png
#>   result.outcome_team1 result.outcome_team2 result.gameWins_team1
#> 1                  win                 loss                     1
#> 2                 loss                  win                     0
#> 3                  win                 loss                     1
#> 4                 loss                  win                     0
#> 5                  win                 loss                     1
#> 6                 loss                  win                     0
#>   result.gameWins_team2 record.wins_team1 record.wins_team2 record.losses_team1
#> 1                     0                14                10                   4
#> 2                     1                 6                 8                  12
#> 3                     0                14                 7                   4
#> 4                     1                 5                 9                  13
#> 5                     0                 8                 9                  10
#> 6                     1                 9                 7                   9
#>   record.losses_team2
#> 1                   8
#> 2                  10
#> 3                  11
#> 4                   9
#> 5                   9
#> 6                  11
```

Next, we juggle some IDs - match and game IDs, to be precise. To get
details of a game, such as Gold, CS, kills, etc. we need the `gameId`.
The schedule above however returns a `matchId`, which *contains*
different `gameId` entries. To illustrate this further, think about a
best-of-5 series between G2 and MAD Lions. The series itself is one
match with one `matchId`. The games within that series however all have
different `gameId` variables, which we would use to get more details
about one specific game in the series.

Below, we will just grab the `gameId` of the best-of-1 match between G2
and MAD that opened the 2021 LEC spring split.

``` r
# Next, we get the ID of the opening match, the first row in the data.frame!
opening_match <- lec_spring_schedule$match.id[1]

# but the matchId is not the gameId we need for detailed queries of match details, 
# which is why we need to grab details of the match, where the respective gameId is saved.
opening_details <- getEventDetails(opening_match)

opening_game_id <- opening_details$games$game_id[1]
```

With the `gameId` as a variable, we can get detailed information about
the match by calling `getCompleteWindow()`.

``` r
g2_vs_mad <- getCompleteWindow(opening_game_id)
#> [1] "Game done, duration: 1.4069mins"
print(g2_vs_mad$data[2500:2510,])
#>      totalGold inhibitors towers barons totalKills dragons
#> 2500      4047          0      0      0          0    NULL
#> 2501      4047          0      0      0          0    NULL
#> 2502      4047          0      0      0          0    NULL
#> 2503      4047          0      0      0          0    NULL
#> 2504      4047          0      0      0          0    NULL
#> 2505      4047          0      0      0          0    NULL
#> 2506      4071          0      0      0          0    NULL
#> 2507      4071          0      0      0          0    NULL
#> 2508      4071          0      0      0          0    NULL
#> 2509      4071          0      0      0          0    NULL
#> 2510      4071          0      0      0          0    NULL
#>                     timestamp gamestate participantId participantGold level
#> 2500 2021-01-22T16:56:30.361Z   in_game             5             639     2
#> 2501 2021-01-22T16:56:30.823Z   in_game             1             783     2
#> 2502 2021-01-22T16:56:30.823Z   in_game             2             983     3
#> 2503 2021-01-22T16:56:30.823Z   in_game             3             859     2
#> 2504 2021-01-22T16:56:30.823Z   in_game             4             783     2
#> 2505 2021-01-22T16:56:30.823Z   in_game             5             639     2
#> 2506 2021-01-22T16:56:31.386Z   in_game             1             799     2
#> 2507 2021-01-22T16:56:31.386Z   in_game             2             985     3
#> 2508 2021-01-22T16:56:31.386Z   in_game             3             861     2
#> 2509 2021-01-22T16:56:31.386Z   in_game             4             785     2
#> 2510 2021-01-22T16:56:31.386Z   in_game             5             641     2
#>      kills deaths assists creepScore currentHealth maxHealth team
#> 2500     0      0       0          1           706       706 blue
#> 2501     0      0       0         10           684       748 blue
#> 2502     0      0       0         15           674       734 blue
#> 2503     0      0       0         11           282       601 blue
#> 2504     0      0       0         10           706       706 blue
#> 2505     0      0       0          1           706       706 blue
#> 2506     0      0       0         11           685       748 blue
#> 2507     0      0       0         15           688       734 blue
#> 2508     0      0       0         11           294       601 blue
#> 2509     0      0       0         10           706       706 blue
#> 2510     0      0       0          1           706       706 blue
#>        esportsPlayerId summonerName  championId    role
#> 2500 99322214629661297     G2 Mikyx     Alistar support
#> 2501 99322214618656216    G2 Wunder      Gragas     top
#> 2502 99124844325223302    G2 Jankos        Olaf  jungle
#> 2503 98767975968177297      G2 Caps TwistedFate     mid
#> 2504 98767991761835561   G2 Rekkles       Sivir  bottom
#> 2505 99322214629661297     G2 Mikyx     Alistar support
#> 2506 99322214618656216    G2 Wunder      Gragas     top
#> 2507 99124844325223302    G2 Jankos        Olaf  jungle
#> 2508 98767975968177297      G2 Caps TwistedFate     mid
#> 2509 98767991761835561   G2 Rekkles       Sivir  bottom
#> 2510 99322214629661297     G2 Mikyx     Alistar support
```

That’s it. Now we have data for the game and could analyze, for example,
the time series of totalGold.

``` r
# Since the data.frame returns one row per team member per team, we need to extract just 
# one row for a given timestamp and team for the aggregated statistics, like totalGold and 
# totalKills. 
library(dplyr)
#> Warning: package 'dplyr' was built under R version 4.0.4
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

plot_df <- g2_vs_mad$data %>% 
  group_by(timestamp, team) %>% 
  select(totalGold, totalKills, timestamp, team) %>% 
  slice_head() %>% 
  arrange(timestamp) %>% 
  distinct(timestamp, team, .keep_all = TRUE) %>% 
  ungroup()

plot_df <- plot_df %>% 
  select(timestamp, totalGold, team) %>% 
  tidyr::pivot_wider(names_from = team, values_from = totalGold) %>% 
  mutate(blue_diff = as.double(blue - red),
         blue_lead = as.factor(sign(blue_diff)),
         y_min = if_else(blue_diff > 0, 0, blue_diff),
         y_max = if_else(blue_diff > 0, blue_diff, 0),
         timestamp = lubridate::ymd_hms(timestamp)) %>% 
  distinct(timestamp, .keep_all = TRUE) %>% 
  tidyr::complete(blue_lead, timestamp, fill = list(blue_diff = 0))

library(ggplot2)

plot_df %>% 
  ggplot(aes(x = timestamp, y = blue_diff, color = blue_lead)) +
  geom_ribbon(data = filter(plot_df, blue_diff <= 0),
    aes(ymax = y_max, ymin = y_min, fill = blue_lead, color = blue_lead),
    outline.type = "lower"
    ) +
  geom_ribbon(data = filter(plot_df, blue_diff >= 0),
    aes(ymax = y_max, ymin = y_min, fill = blue_lead, color = blue_lead),
    outline.type = "upper"
    ) +
  scale_color_manual(values = c("red", "black", "blue")) +
  ylim(c(-2500, max(plot_df$blue_diff))) + 
  xlab("") + ylab("") + 
  ggtitle("Gold Difference between G2 (blue) and MAD (red)") +
  theme(legend.position = "none",
        panel.background = element_rect(fill = "grey"),
        plot.background = element_rect(fill = "grey"),
        panel.grid = element_line(colour = "grey"),
        title = element_text())
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -
#> Inf
#> Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning -
#> Inf
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
