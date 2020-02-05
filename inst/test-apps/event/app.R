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
    // hack to also dispatch a native DOM event on every jQuery shiny:inputchanged
    $(document).on('shiny:inputchanged', function(e) {
      var event = new CustomEvent('shinynative:inputchanged', { detail: e });
      window.dispatchEvent(event);
    })
  ")),
  shiny::titlePanel("vegawidget signal example"),
  tags$p(
"
I had hoped to demonstrate vega signals based on shiny JS events.  Unfortunately, shiny JS events
are jQuery triggered events and not native DOM events.  Vega only sees native DOM events.  We
can overcome with a hack, but this is likely not a viable robust strategy going forward.  For
future reference, I thought a quick example would be helpful.
"
  ),
  shiny::fluidRow(
    column(
      width = 3,
      shiny::sliderInput(
        "slider",
        label = "Cylinders",
        min = 4,
        max = 8,
        step = 2,
        value = 4
      )
    ),
    column(
      width = 3,
      tags$input(
        type = "range",
        id = "domslider",
        min = "4",
        max = "8",
        value = "6",
        step = 2
      )
    )
  ),
  shiny::fluidRow(
    tagList(
      h3("vega chart"),
      vegawidgetOutput("chart")
    )
  ),
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

