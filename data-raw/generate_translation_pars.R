## Takes params and compiles them into default parameters used throughout the
## app and also generates the translation file

languages <- c("eng", "tet", "por")
names(languages) <- languages
params <- lapply(languages, function(x) config::get(file = "app_params.yml", config = x))
unlisted_params <- lapply(params, unlist)

to_df <- function(x){
  lang <- names(unlisted_params[x])
  x <- unlisted_params[[x]]
  df <- data.frame(names(x), x)
  names(df) <- c("par_name", lang)
  df
}
params_as_df <- lapply(seq_along(unlisted_params), to_df)


multilingual <- Reduce(merge, params_as_df)
multilingual <- apply(multilingual, 1, function(x) x[-1], simplify = F)
multilingual <- lapply(multilingual, as.list)


no_translation <- function(x){
  x$eng == x$tet & x$eng == x$por
}

# remove elements where all are the same (no translation available)
multilingual <- multilingual[!unlist(lapply(multilingual, no_translation))]

trans_json <- list(
  cultural_date_format = "%d-%m-%Y",
  languages = c("eng", "tet", "por"),
  translation = multilingual
)

jsonlite::write_json(trans_json, "inst/translation.json", auto_unbox = T, pretty = F)

pars <- params$eng
usethis::use_data(pars, overwrite = TRUE)

