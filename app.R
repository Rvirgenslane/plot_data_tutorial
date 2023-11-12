library(shiny)

# rm(list = ls())
source(file.path(getwd(), "helpers.R"))

# load data
path_yaml <- file.path(Sys.getenv("HOME"),
"Documents", "google_sheet_proj.yaml")

yaml_url <- yaml::read_yaml(file = path_yaml) %>% 
purrr::chuck("google_sheet_url")

# ui ----------------------------------------------------------------------

# k-means only works with numerical variables,
# so don't give the user the option to select
# a categorical variable





ui <- pageWithSidebar(
headerPanel('Plot the data'),
sidebarPanel(width = 2,

shiny::actionButton(inputId = "load_url",
label = "load data",
class = "btn-success"  ),
shiny::conditionalPanel(
condition = "input.tab =='Plot'",



selectInput('ycol', 'Y Variable', ""),
selectInput('xcol', 'X Variable', ""),

selectInput('facet', 'facet Variable', "")

)
),
mainPanel(
shiny::tabsetPanel(id = "tab",
  
  shiny::tabPanel("Track",
                  shiny::plotOutput('plot2')
                  ),  
shiny::tabPanel("Plot",
shiny::plotOutput('plot1'),
DT::dataTableOutput(outputId = "all_dat"))
)

)
)

# server ------------------------------------------------------------------

server <- function(input, output, session) {




# update data
observe({

vars_d <- shiny::req(selectedData())

vars <- setdiff(names(vars_d), c("subject_id", "jump_1_in",
         "jump_2_in", "jump_3_in"))

shiny::updateSelectInput(inputId =  'xcol', 
choices = vars %>% 
 stringr::str_subset(pattern = "jump",
                     negate = TRUE),
session = session)

shiny::updateSelectInput(inputId = 'ycol',
choices = vars,
session = session,

selected = character(0))

shiny::updateSelectInput(inputId = 'facet',
choices = vars  %>% 
 stringr::str_subset(pattern = "jump",
                     negate = TRUE),
session = session,

selected = character(0))

})
# Combine the selected variables into a new data frame
selectedData <- shiny::reactive({
shinybusy::show_modal_spinner(session = session)
merg_dat <- load_data_(url = yaml_url) %>%
dplyr::mutate(age_years = .data$age_years %>% as.factor()) %>% 
dplyr::mutate(dplyr::across(is.numeric, round, digits = 1)) 

shinybusy::remove_modal_spinner(session = session)

return(merg_dat)

}) %>% shiny::bindEvent(input$load_url)


output$all_dat <- DT::renderDataTable(
{shiny::req(selectedData())},
filter = "top",
selection = 'none',
options = list(scrollX = TRUE)

)


output$plot1 <- renderPlot({


x_var <- shiny::req(input$xcol)
y_var <- shiny::req(input$ycol)
facet_ <- NULL

if(shiny::isTruthy(input$facet)){
facet_ <- input$facet

}

selectedData() %>% 
ggplot2::ggplot(ggplot2::aes(y = .data[[y_var]], 
     fill = .data[[x_var]],
x = .data[[x_var]])) +
ggplot2::geom_boxplot() +
ggplot2::geom_point() +
ggplot2::facet_wrap(facet_,
labeller = label_both) +
ggplot2::theme_classic(base_size = 16) +
ggplot2::scale_fill_brewer(palette = "Set2")
})

}



# app ---------------------------------------------------------------------

shiny::shinyApp(ui = ui, server = server)
