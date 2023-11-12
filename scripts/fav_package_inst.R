
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.18")

# other packages
# ?googlesheets4::write_sheet()
install.packages(c("googlesheets4", "ggplot2", 
                   "janitor", "ggpubr", "shiny",
                   "shinybusy", "ids", "DT",
                   "tidyverse"))

install.packages("shinybusy")

