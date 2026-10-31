library(shiny)
library(bslib)

# Share of the population with access to electricity, by region and for the world
access <- read.csv("electricity-access.csv")
regions <- setdiff(unique(access$area), "World")

ui <- page_sidebar(
  title = "Access to electricity by region",
  sidebar = sidebar(
    selectInput(
      "region",
      "Regions",
      choices = regions,
      selected = "Sub-Saharan Africa",
      multiple = TRUE
    ),
    sliderInput(
      "years",
      "Years",
      min = min(access$year),
      max = max(access$year),
      value = range(access$year),
      step = 1,
      sep = ""
    )
  ),
  card(
    card_header(textOutput("heading")),
    plotOutput("trend")
  )
)

server <- function(input, output, session) {
  output$heading <- renderText({
    req(input$region)
    paste(paste(input$region, collapse = ", "), "compared with the world")
  })

  output$trend <- renderPlot(
    {
      req(input$region)
      in_range <- access[
        access$year >= input$years[1] & access$year <= input$years[2],
      ]
      world <- in_range[in_range$area == "World", ]
      cols <- hcl.colors(length(input$region), "Dark 3")
      plot(
        world$year,
        world$access,
        type = "l",
        lty = 2,
        lwd = 2,
        col = "#52514e",
        ylim = c(0, 100),
        xlab = "",
        ylab = "% of population",
        las = 1,
        bty = "n"
      )
      for (i in seq_along(input$region)) {
        region <- in_range[in_range$area == input$region[i], ]
        lines(region$year, region$access, lwd = 3, col = cols[i])
      }
      n <- length(cols)
      legend(
        "bottomright",
        legend = c(input$region, "World"),
        col = c(cols, "#52514e"),
        lty = c(rep(1, n), 2),
        lwd = c(rep(3, n), 2),
        bty = "n"
      )
    },
    res = 96
  )
}

shinyApp(ui, server)
