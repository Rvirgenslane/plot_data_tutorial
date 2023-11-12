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
  sidebarPanel(
    shiny::actionButton(inputId = "load_url",
                        label = "load data",
                        class = "btn-success"  ),
    selectInput('xcol', 'X Variable', ""),
    selectInput('ycol', 'Y Variable', ""),
    selectInput('facet', 'facet Variable', "")
  ),
  mainPanel(
    plotOutput('plot1')
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
    merg_dat <- load_data_(url = yaml_url)
    
    shinybusy::remove_modal_spinner(session = session)
    
    return(merg_dat)

  }) %>% shiny::bindEvent(input$load_url)
  

  
  
  output$plot1 <- renderPlot({
    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
              "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
    
    x_var <- shiny::req(input$xcol)
    y_var <- shiny::req(input$ycol)
    facet_ <- NULL
    if(shiny::isTruthy(input$facet)){
      facet_ <- input$facet
      
    }
    
    selectedData() %>% 
      ggplot2::ggplot(ggplot2::aes(y = .data[[y_var]], 
                 x = .data[[x_var]])) +
      ggplot2::geom_boxplot() +
      ggplot2::geom_point() +
      ggplot2::facet_wrap(facet_,
                          labeller = label_both) +
      ggplot2::theme_classic(base_size = 16)
  })
  
}



# app ---------------------------------------------------------------------

shiny::shinyApp(ui = ui, server = server)