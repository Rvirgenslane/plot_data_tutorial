library(shiny)

# rm(list = ls())
source(file.path(getwd(), "helpers.R"))

# load data
path_yaml <- file.path(Sys.getenv("HOME"),
                       "Documents", "google_sheet_proj.yaml")

yaml_url <- yaml::read_yaml(file = path_yaml) %>% 
  purrr::chuck("google_sheet_url")

merge_dat <- load_data_(url = yaml_url)
merge_dat %>% names()

merge_dat %>% 
  dplyr::summarise(n = dplyr::n()) %>% 
  dplyr::pull("n") 

##
x_var_density <- "max_jump"
disc_var <- c("age_years", "sex", "group", NULL)[2]

total_counts <- merge_dat %>% 
  dplyr::pull(x_var_density) %>% 
  unique() %>% length()

merge_dat %>% 
  
  ggpubr::ggdensity( x = x_var_density,
            add = "mean",
            rug = TRUE,
            title = glue::glue("total counts: {total_counts}"),
            color = disc_var,
            fill = disc_var) +
  ggplot2::scale_fill_brewer(palette = "Set2") +
  ggplot2::scale_color_brewer(palette = "Set2")

