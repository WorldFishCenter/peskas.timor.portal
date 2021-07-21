## code to prepare `var_dictionary` dataset goes here

var_dictionary <- yaml::read_yaml("inst/var_dictionary.yml")
usethis::use_data(var_dictionary, overwrite = TRUE)
