

library(dplyr)
# pre
path_yaml <- file.path("~/Documents", "google_sheet_proj.yaml")

rvs_url <- yaml::read_yaml(file = path_yaml) %>% 
  purrr::chuck("google_sheet_url")



# make ids ----------------------------------------------------------------


set.seed(12)
size <- 80

randos <- ids::random_id(size, 2, use_openssl = FALSE)
randos

# syn data ----------------------------------------------------------------

age <- sample(seq(10,11), size = size, replace = TRUE)
# plot(hist(age))

height <-rnorm(n = size, mean = c(48+11))
# plot(hist(height))
sex_ <- sample(c("M", "F", "U"), size = size, replace = TRUE)
group_ <- sample(c("A", "B"), size = size, replace = TRUE)


sbj_dat <- tibble::as_tibble(randos) %>% 
  purrr::set_names("subject_id") %>% 
  dplyr::mutate(
    age_years = age,
    height_in	 = height,
    sex = sex_,
    group = group_
  )

sbj_dat

set.seed(12)

acti_dat <- tibble::as_tibble(randos) %>% 
  purrr::set_names("subject_id") %>% 
  dplyr::mutate(
    jump_1_in = rnorm(n = size, mean = c(59.0551)),
    jump_2_in	 = rnorm(n = size, mean = c(59.0551)),
    jump_3_in = rnorm(n = size, mean = c(59.0551))
  )

acti_dat # %>% View()
  

# 
list_dat <- list(subject_metadata = sbj_dat,
                 activity_assay = acti_dat)
list_dat 


list_dat %>% 
  purrr::imap(function(x,y){
    googlesheets4::write_sheet(data = x, ss = rvs_url, sheet = y)
  })


# write empty -------------------------------------------------------------

sbj_dat_empty <- tibble::as_tibble(randos) %>% 
  purrr::set_names("subject_id") %>% 
  dplyr::mutate(
    age_years = NA,
    height_in	 = NA,
    sex = NA,
    group = NA
  )

sbj_dat_empty


acti_dat_empty <- tibble::as_tibble(randos) %>% 
  purrr::set_names("subject_id") %>% 
  dplyr::mutate(
    jump_1_in = NA,
    jump_2_in	 = NA,
    jump_3_in = NA
  )

acti_dat_empty


list_dat_empty <- list(subject_metadata = sbj_dat_empty,
                 activity_assay = acti_dat_empty)

list_dat_empty
##

list_dat_empty %>% 
  purrr::imap(function(x,y){
    googlesheets4::write_sheet(data = x, ss = rvs_url, sheet = y)
  })

