## Takes params and compiles them into default parameters used throughout the
## app and also generates the translation file

library(magrittr)

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

no_translation <- function(x){
  x$eng == x$tet & x$eng == x$por
}

multilingual <- Reduce(merge, params_as_df)
multilingual <- multilingual %>%
  dplyr::group_by(par_name) %>%
  dplyr::filter(!no_translation(data.frame(eng, tet, por))) %>%
  dplyr::ungroup() %>%
  dplyr::distinct(eng, tet, por, .keep_all = T)
multilingual <- apply(multilingual, 1, function(x) x[-1], simplify = F)
multilingual <- lapply(multilingual, as.list)


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

# taxa names
pars$taxa$to_display
n <- lapply(pars$taxa$taxa, function(x){x$short_name}) %>% unlist()

library(data.table)

taxa_names <- data.table(
  grouped_taxa = names(n),
  grouped_taxa_names = n
)

get_taxa_descending_order <- function(){
  # beginning of current year
  start <- as.Date(paste0(format(Sys.Date(), "%Y"), "-01-01"))
  # specific taxa (without other)
  taxa <- pars$taxa$to_display[pars$taxa$to_display != "MZZ"]
  x <- peskas.timor.portal::taxa_aggregated$month[date_bin_start >= start]
  x <- x[grouped_taxa %in% taxa]
  x <- x[, .(catch = sum(catch)), by = "grouped_taxa"]
  c(x[order(-catch), grouped_taxa], "MZZ")
}
taxa_names <- taxa_names[grouped_taxa %in% get_taxa_descending_order()]
taxa_names <- taxa_names[, grouped_taxa := factor(grouped_taxa, get_taxa_descending_order())]
taxa_names <- taxa_names[order(grouped_taxa)]
usethis::use_data(taxa_names, overwrite = TRUE)
