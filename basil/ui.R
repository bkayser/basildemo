library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Basil Parameter Tuning"),
    
    # Sidebar with a slider input for the number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("leadin",
                        "Consecutive Violations to Trigger/Clear:",
                        min = 1,
                        max = 20,
                        value = 5),
            sliderInput("nsigma",
                        "Number of sigmas for threshold:",
                        min = 1,
                        max = 10,
                        value = 4)
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("charts")
        )
    )
))