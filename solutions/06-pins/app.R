# To use this version, copy it over electricity-app/app.R. It no longer needs
# electricity-access.csv, so delete that file and refresh the manifest:
# rsconnect::writeManifest("electricity-app")

library(shiny)
library(bslib)
library(pins)

# Share of the population with access to electricity, by region and for the world,
# read from a pin on Posit Connect instead of a file stored with the app.
board <- board_connect()
pin_name <- "francois/electricity_access"

ui <- page_sidebar(
  title = "Electricity access explorer",
  sidebar = sidebar(
    uiOutput("controls")
  ),
  card(
    card_header(textOutput("heading")),
    plotOutput("trend")
  )
)

server <- function(input, output, session) {
  # Read the pin each time someone opens the app, so a new version of the data
  # shows up on the next visit without redeploying the app.
  access <- pin_read(board, pin_name)
  regions <- setdiff(unique(access$area), "World")
  years <- range(access$year)

  # The year range comes from the data, so the slider grows when the pin does.
  output$controls <- renderUI(tagList(
    selectInput("region", "Region", choices = regions, selected = "Sub-Saharan Africa"),
    sliderInput("years", "Years", min = years[1], max = years[2], value = years,
                step = 1, sep = "")
  ))

  output$heading <- renderText({
    req(input$region)
    paste(input$region, "compared with the world")
  })

  output$trend <- renderPlot({
    req(input$region, input$years)
    shown <- access[access$year >= input$years[1] & access$year <= input$years[2], ]
    region <- shown[shown$area == input$region, ]
    world <- shown[shown$area == "World", ]
    plot(world$year, world$access, type = "l", lty = 2, lwd = 2, col = "#52514e",
         ylim = c(0, 100), xlab = "", ylab = "% of population", las = 1, bty = "n")
    lines(region$year, region$access, lwd = 3, col = "#2a78d6")
    legend("bottomright", legend = c(input$region, "World"), col = c("#2a78d6", "#52514e"),
           lty = c(1, 2), lwd = c(3, 2), bty = "n")
  }, res = 96)
}

shinyApp(ui, server)
