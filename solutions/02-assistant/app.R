# To use this version, copy it over electricity-app/app.R.

library(shiny)
library(bslib)

# Share of the population with access to electricity, by region and for the world
access <- read.csv("electricity-access.csv")
regions <- setdiff(unique(access$area), "World")
years <- range(access$year)

ui <- page_sidebar(
  title = "Electricity access explorer",
  sidebar = sidebar(
    selectInput("region", "Region", choices = regions, selected = "Sub-Saharan Africa"),
    sliderInput("years", "Years", min = years[1], max = years[2], value = years,
                step = 1, sep = "")
  ),
  card(
    card_header(textOutput("heading")),
    plotOutput("trend")
  )
)

server <- function(input, output, session) {
  output$heading <- renderText(paste(input$region, "compared with the world"))

  output$trend <- renderPlot({
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
