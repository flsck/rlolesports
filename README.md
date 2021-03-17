
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

Example is tbd, we’ll take a look at the getWindow function later.

``` r
library(rlolesports)
## basic example code
```
