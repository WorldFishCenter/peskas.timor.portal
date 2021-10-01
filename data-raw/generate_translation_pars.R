## Takes params and compiles them into default parameters used throughout the
## app and also generates the translation file

languages <- c("eng", "tet", "por")
names(languages) <- languages
params <- lapply(languages, function(x) config::get(file = "data-raw/app_params.yml", config = x))
unlisted_params <- lapply(params, unlist)

merge_lang <- function(eng, tet, por){
  list(eng = eng, tet = tet, por = por)
}

multilingual <- mapply(merge_lang,
                       unlisted_params$eng,
                       unlisted_params$tet,
                       unlisted_params$por,
                       SIMPLIFY = FALSE)
names(multilingual) <- NULL

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

jsonlite::write_json(trans_json, "inst/translation.json", auto_unbox = T, pretty = T)

pars <- params$eng
usethis::use_data(pars, overwrite = TRUE)

