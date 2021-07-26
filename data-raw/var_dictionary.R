## code to prepare `var_dictionary` dataset goes here

var_dictionary <- yaml::read_yaml("data-raw/var_dictionary.yml")
usethis::use_data(var_dictionary, overwrite = TRUE)
