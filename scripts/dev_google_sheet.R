library(googlesheets4)
library(ggplot2)


path_yaml <- file.path("~/Documents", "google_sheet_proj.yaml")

rvs_url <- yaml::read_yaml(file = path_yaml) %>% 
  purrr::chuck("google_sheet_url")

# subject metadata --------------------------------------------------------


sub_metadata <-googlesheets4::read_sheet(rvs_url, sheet = "subject_metadata") %>% 
  janitor::remove_empty(which = c("rows", "cols")) %>% 
dplyr::mutate(dplyr::across(dplyr::any_of(c("sex", "group")),as.factor))#%>% 

sub_metadata
  #dplyr::mutate_if(is.character, as.factor)

# check for non-unique ids

if(any(duplicated(sub_metadata$subject_id))){
  warning("non unique ids detected")
}


# activity assay calculations ---------------------------------------------

activity_dat <- googlesheets4::read_sheet(rvs_url, sheet = "activity_assay") %>% 
  dplyr::mutate(
    
    avg_jump = c(.data$jump_1_in + .data$jump_2_in + .data$jump_3_in) / 3,
    min_jump = min(c(.data$jump_1_in, .data$jump_2_in, .data$jump_3_in)), 
    median_jump = median(c(.data$jump_1_in, .data$jump_2_in, .data$jump_3_in)), 
    max_jump = max(c(.data$jump_1_in, .data$jump_2_in, .data$jump_3_in)), 
    
    .by = "subject_id"

    
    ) %>% 
  janitor::remove_empty(which = c("rows", "cols"))


# check ids

if(any(duplicated(activity_dat$subject_id))){
  warning("non unique ids detected")
}

activity_dat 

# merged_data -------------------------------------------------------------

merg_dat <- activity_dat %>% 
  dplyr::left_join(sub_metadata, by = "subject_id")

merg_dat


# plotting data -----------------------------------------------------------


x_var <- c("sex", "group")[1]
y_var <- c("max_jump", "median_jump", "avg_jump")[2]

x_var
y_var


# discrete variables ------------------------------------------------------
merg_dat %>% 
  ggplot(aes(y = .data[[y_var]], 
             x = .data[[x_var]])) +
  geom_boxplot() +
  geom_point()



# continuous variables ----------------------------------------------------

y_var_c <- c("max_jump", "median_jump", "avg_jump")[2]
x_var_c <- c("age_years", "height_in")[1]

library(ggpubr)

merg_dat %>% 
  ggplot(aes(y = .data[[y_var_c]], 
             x = .data[[x_var_c]])) +
  geom_point()


####
merg_dat %>% 
  
ggscatter(
 x = x_var_c, y = y_var_c,
  color = "sex",
 palette = "jco",
  add = "reg.line"
) +
  #facet_wrap(~group) +
  stat_cor()
  #stat_regline_equation()

