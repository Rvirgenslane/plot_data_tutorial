library(googlesheets4)
library(ggplot2)


load_data_ <- function(url = NULL){
  
  sub_metadata <- googlesheets4::read_sheet( ss = url ,
                                             sheet = "subject_metadata") %>% 
    janitor::remove_empty(which = c("rows", "cols")) %>% 
    dplyr::mutate(dplyr::across(dplyr::any_of(c("sex", "group")),as.factor))#%>% 
  
  sub_metadata
  #dplyr::mutate_if(is.character, as.factor)
  
  # check for non-unique ids
  
  if(any(duplicated(sub_metadata$subject_id))){
    warning("non unique ids detected")
  }
  
  
  # activity assay calculations ---------------------------------------------
  
  activity_dat <- googlesheets4::read_sheet(ss = url ,
                                            sheet = "activity_assay") %>% 
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
  
 # activity_dat 
  
  # merged_data -------------------------------------------------------------
  
  merg_dat <- activity_dat %>% 
    dplyr::left_join(sub_metadata, by = "subject_id")
  
  return(merg_dat)
  
}