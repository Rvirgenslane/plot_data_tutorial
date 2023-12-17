library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  HTMLOutput("holiday_animation"),
  selectInput("holiday_selector", "Select Holiday", c("New Year's Day", "Independence Day", "Thanksgiving"))
)

server <- function(input, output) {
  output$holiday_animation <- renderUI({
    holiday <- input$holiday_selector
    
    # HTML and CSS code for different holidays
    html_code <- sprintf('
      <div id="holiday_div" class="animated">
        <p>%s</p>
      </div>
    ', holiday)
    
    # JavaScript to handle animation logic (animate.css)
    js_code <- '
      $(document).ready(function(){
        $("#holiday_div").addClass("animate__animated animate__fadeIn");
      });
    '
    
    # Using shinyjs to run the JavaScript code
    shinyjs::runjs(js_code)
    
    HTML(html_code)
  })
}

shinyApp(ui, server)
