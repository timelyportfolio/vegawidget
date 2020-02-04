# This is an example shiny application that uses a vega schema with a signal
# defined.  The app adds a click listener that prints the value of the data point.
# It also binds a slider UI element to the signal, which is used in the spec
# to filter the points.

library("shiny")
library("vegawidget")

spec <-
  jsonlite::fromJSON("example_vega_schema.json") %>%
  as_vegaspec()

ui <- shiny::fluidPage(
  tags$script(HTML("
    $(document).on('shiny:inputchanged', function(e) {
      var event = new CustomEvent('shiny_inputchanged', { detail: e });
      window.dispatchEvent(event);
    })
  ")),
  shiny::titlePanel("vegawidget signal example"),
  shiny::fluidRow(
    shiny::sliderInput(
      "slider",
      label = "Cylinders",
      min = 4,
      max = 8,
      step = 2,
      value = 4
    )
  ),
  shiny::fluidRow(vegawidgetOutput("chart")),
  shiny::fluidRow(shiny::verbatimTextOutput("cl"))

)

# Define server logic
server <- function(input, output) {

  # outputs
  output$chart <- renderVegawidget(spec)

  output$cl <- renderPrint(input$slider)
}

# Run the application
shiny::shinyApp(ui = ui, server = server)

