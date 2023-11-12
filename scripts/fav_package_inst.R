
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(version = "3.18")

# other packages

install.packages(c("googlesheets4", "ggplot2", 
                   "janitor", "ggpubr", "shiny",
                   "shinybusy",
                   "tidyverse"))

install.packages("shinybusy")


